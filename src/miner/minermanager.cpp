#include "minermanager.h"


#include <QDir>
#include <QString>

#include <string>
#include <iostream>

#include <QFileInfo>

namespace minerconfig {
#if defined(Q_OS_WIN)
	const std::string MINER_NAME = "bittube-miner.exe";
	//const std::string MINER_FOLDER = "/build/release/bin/miner/";// DevPath
	const std::string MINER_FOLDER = "/miner/"; // ReleasePath
#elif defined(Q_OS_LINUX)
	const std::string MINER_NAME = "bittube-miner.exe";//TODO: ...
	const std::string MINER_FOLDER = "/build/release/bin/miner/";//TODO: ...
#else // Mac¿? miner in mac¿?
	const std::string MINER_NAME = "bittube-miner.exe";//TODO: ...
	const std::string MINER_FOLDER = "/build/release/bin/miner/";//TODO: ...
#endif
}


MinerManager::MinerManager(QObject* parent) : QObject(parent) {
	std::string pathTmp = minerconfig::MINER_FOLDER + minerconfig::MINER_NAME;
	restart = true;
	//QString file = QDir::currentPath() + "/build/release/bin/miner/bittube-miner.exe";
	QString file = QDir::currentPath() +  QString::fromStdString(pathTmp);
	QFileInfo check_file(file);

	if (check_file.exists() && check_file.isFile()) {
		std::cout << "[MinerManager] - miner binary app, found." << std::endl;

		m_process = new QProcess(this);

		connect(m_process, SIGNAL(readyReadStandardOutput()), this, SLOT(showMinerOutput()) );
		connect(m_process, SIGNAL(stateChanged(QProcess::ProcessState)), this, SLOT(stateChangeEvent(QProcess::ProcessState)) );
		//m_process->setWorkingDirectory(QDir::currentPath() + "/build/release/bin/miner/");
		m_process->setWorkingDirectory(QDir::currentPath() + QString::fromStdString(minerconfig::MINER_FOLDER));
		m_process->start(file);
		//m_process->startDetached(file);
	} else {
		std::cout << "[MinerManager] - Error: miner binary app, not found." << std::endl;
		//TODO: more error handling ¿?
	}
}

MinerManager::~MinerManager() {
	restart = false;
	if (m_process != nullptr) {
		if(m_process->state() != QProcess::NotRunning) {
			m_process->close();
			m_process->waitForFinished(30000);
		}
		delete m_process;
		m_process = nullptr;
	}
};

void MinerManager::showMinerOutput() {
	std::cout << "[MinerConsole]-" << m_process->readAllStandardOutput().toStdString() << std::endl;
}

void MinerManager::stateChangeEvent(QProcess::ProcessState newState) {
	std::cout << "[MinerManager] - >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Miner state changed: " << newState << std::endl;

	std::string pathTmp = minerconfig::MINER_FOLDER + minerconfig::MINER_NAME;
	QString file = QDir::currentPath() +  QString::fromStdString(pathTmp);

	if ((newState == QProcess::NotRunning) && (restart)){
		//std::cout << "Miner is not running" << std::endl;
		restart = true;
		m_process->start(file);
	}
}