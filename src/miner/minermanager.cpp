#include "minermanager.h"

#include <QProcess>
#include <QDir>
#include <QString>
#include <iostream>


MinerManager::MinerManager(QObject* parent) : QObject(parent) {
    m_process = new QProcess(this);

    //std::cout << "homePath: " << QDir::homePath().toStdString() << std::endl;
    std::cout << "currentPath: " << QDir::currentPath().toStdString() << std::endl;

    // C:/Users/Anto/Documents/Development/GRP_workspace/OtherProjects/bittube-coin-gui-wallet
    QString file = QDir::currentPath() + "/build/release/bin/miner/bittube-miner.exe";
    //QString file = QDir::currentPath() + "\miner\ipbc-miner.exe";

    connect(m_process, SIGNAL(readyReadStandardOutput()), this, SLOT(showMinerOutput()) );
    m_process->setWorkingDirectory(QDir::currentPath() + "/build/release/bin/miner/");
    m_process->start(file);
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