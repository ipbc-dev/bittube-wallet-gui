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

#if defined(Q_OS_WIN)
//#include <System.dll>

#include <windows.h>
#include <tlhelp32.h>
#include <stdio.h>

//using namespace System;
//using namespace System::Diagnostics;
//using namespace System::ComponentModel;
#elif defined(Q_OS_LINUX)

#else // Mac¿? miner in mac¿?

#endif

bool MinerManager::checkExternalRunning () {
	bool result = false;

	//std::string pathTmp = minerconfig::MINER_FOLDER + minerconfig::MINER_NAME;
	std::string pathTmp = minerconfig::MINER_NAME;
	//char *szProcessToKill = pathTmp.c_str();
	char *szProcessToKill = new char[pathTmp.length() + 1];
	strcpy(szProcessToKill, pathTmp.c_str());

	#if defined(Q_OS_WIN)

	//std::string FilePath = Path.GetDirectoryName(pathTmp);
    //std::string FileName = Path.GetFileNameWithoutExtension(pathTmp).ToLower();
    //bool isRunning = false;

    //Process[] pList = Process.GetProcessesByName(FileName);

    //foreach (Process p in pList) {
    //    if (p.MainModule.FileName.StartsWith(FilePath, StringComparison.InvariantCultureIgnoreCase))
    //    {
    //        result = true;
    //        break;
    //    }
    //}

    HANDLE hProcessSnap;
	HANDLE hProcess;
	PROCESSENTRY32 pe32;
	DWORD dwPriorityClass;

	hProcessSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);  // Takes a snapshot of all the processes

	if(hProcessSnap == INVALID_HANDLE_VALUE){
		return( FALSE );
	}

	pe32.dwSize = sizeof(PROCESSENTRY32);

	if(!Process32First(hProcessSnap, &pe32)){
		CloseHandle(hProcessSnap);     
		return( FALSE );
	}
	std::cout << "[MinerManager] - Process to search name: " << static_cast <const char *>(szProcessToKill) << std::endl;
	do {
		std::wstring ws(pe32.szExeFile);
		std::string s(ws.begin(), ws.end());
		//std::cout << "[MinerManager] - Process name: " << s << std::endl;
		//if (!strcmp((char*)pe32.szExeFile, szProcessToKill)){    //  checks if process at current position has the name of to be killed app
		if(!strcmp(s.c_str(), pathTmp.c_str())){    //  checks if process at current position has the name of to be killed app
			//std::cout << "[MinerManager] - Found external miner... +++---+++" << std::endl;
			hProcess = OpenProcess(PROCESS_TERMINATE,0, pe32.th32ProcessID);  // gets handle to process
			TerminateProcess(hProcess,0);   // Terminate process by handle
			CloseHandle(hProcess);  // close the handle
		} 
	} while(Process32Next(hProcessSnap,&pe32));  // gets next member of snapshot

	CloseHandle(hProcessSnap);  // closes the snapshot handle
	return( TRUE );
//-----------------------------------------------------------------------------------------------------------------------------------------
	#elif defined(Q_OS_LINUX)

	#else // Mac¿? miner in mac¿?

	#endif

	return result;
}

MinerManager::MinerManager(QObject* parent) : QObject(parent) {
	std::string pathTmp = minerconfig::MINER_FOLDER + minerconfig::MINER_NAME;
	restart = true;

	//checkExternalRunning ();

	//QString file = QDir::currentPath() + "/build/release/bin/miner/bittube-miner.exe";
	QString file = QDir::currentPath() + QString::fromStdString(pathTmp);
	QFileInfo check_file(file);
	QStringList arguments;
	arguments << "-noExpert";

	if (check_file.exists() && check_file.isFile()) {
		std::cout << "[MinerManager] - miner binary app, found." << std::endl;

		m_process = new QProcess(this);

		connect(m_process, SIGNAL(readyReadStandardOutput()), this, SLOT(showMinerOutput()) );
		connect(m_process, SIGNAL(stateChanged(QProcess::ProcessState)), this, SLOT(stateChangeEvent(QProcess::ProcessState)) );
		//m_process->setWorkingDirectory(QDir::currentPath() + "/build/release/bin/miner/");
		m_process->setWorkingDirectory(QDir::currentPath() + QString::fromStdString(minerconfig::MINER_FOLDER));
		m_process->start("\"" + file + "\"", arguments);
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
	QFileInfo check_file(file);
	QStringList arguments;
	arguments << "-noExpert";

	if ((newState == QProcess::NotRunning) && (restart)){
		//std::cout << "Miner is not running" << std::endl;
		restart = true;

		checkExternalRunning ();

		//connect(m_process, SIGNAL(readyReadStandardOutput()), this, SLOT(showMinerOutput()) );
		//connect(m_process, SIGNAL(stateChanged(QProcess::ProcessState)), this, SLOT(stateChangeEvent(QProcess::ProcessState)) );


		//m_process->start(file);

		m_process = new QProcess(this);

		connect(m_process, SIGNAL(readyReadStandardOutput()), this, SLOT(showMinerOutput()) );
		connect(m_process, SIGNAL(stateChanged(QProcess::ProcessState)), this, SLOT(stateChangeEvent(QProcess::ProcessState)) );
		//m_process->setWorkingDirectory(QDir::currentPath() + "/build/release/bin/miner/");
		m_process->setWorkingDirectory(QDir::currentPath() + QString::fromStdString(minerconfig::MINER_FOLDER));
		m_process->start("\"" + file + "\"");
		m_process->start("\"" + file + "\"", arguments);
	}
}