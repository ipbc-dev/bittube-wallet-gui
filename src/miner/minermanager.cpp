#include "minermanager.h"

#include <QProcess>
#include <QDir>
#include <QString>
#include <iostream>


MinerManager::MinerManager(QObject* parent) : QObject(parent) {
    m_process = new QProcess();

    //std::cout << "homePath: " << QDir::homePath().toStdString() << std::endl;
    std::cout << "currentPath: " << QDir::currentPath().toStdString() << std::endl;

    // C:/Users/Anto/Documents/Development/GRP_workspace/OtherProjects/bittube-coin-gui-wallet
    QString file = QDir::currentPath() + "/build/release/bin/miner/bittube-miner.exe";
    //QString file = QDir::currentPath() + "\miner\ipbc-miner.exe";
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