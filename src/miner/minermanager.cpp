#include "minermanager.h"

#include <QProcess>
#include <QDir>
#include <QString>

#include <string>
#include <iostream>

#include <QFileInfo>

namespace minerconfig {
#if defined(Q_OS_WIN)
	const std::string MINER_NAME = "bittube-miner.exe";
	const std::string MINER_FOLDER = "/build/release/bin/miner/";
#elif defined(Q_OS_LINUX)
	const std::string MINER_NAME = "bittube-miner.exe";//TODO: ...
	const std::string MINER_FOLDER = "/build/release/bin/miner/";//TODO: ...
#elif // Mac¿? miner in mac¿?
	const std::string MINER_NAME = "bittube-miner.exe";//TODO: ...
	const std::string MINER_FOLDER = "/build/release/bin/miner/";//TODO: ...
#endif
}


MinerManager::MinerManager(QObject* parent) : QObject(parent) {
	std::string pathTmp = minerconfig::MINER_FOLDER + minerconfig::MINER_NAME;
	//QString file = QDir::currentPath() + "/build/release/bin/miner/bittube-miner.exe";
	QString file = QDir::currentPath() +  QString::fromStdString(pathTmp);
	QFileInfo check_file(file);

	if (check_file.exists() && check_file.isFile()) {
		std::cout << "[MinerManager] - miner binary app, found." << std::endl;

		m_process = new QProcess(this);

		connect(m_process, SIGNAL(readyReadStandardOutput()), this, SLOT(showMinerOutput()) );
		m_process->setWorkingDirectory(QDir::currentPath() + "/build/release/bin/miner/");
		m_process->start(file);
		//m_process->startDetached(file);
	} else {
		std::cout << "[MinerManager] - Error: miner binary app, not found." << std::endl;
		//TODO: more error handling ¿?
	}
}

MinerManager::~MinerManager() {
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