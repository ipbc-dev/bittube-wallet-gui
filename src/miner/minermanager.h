#pragma once

#include <QObject>
#include <QProcess>

class QProcess;


class MinerManager : public QObject {
	Q_OBJECT

	public:
		explicit MinerManager(QObject* parent = 0);
		virtual ~MinerManager();

	public slots:
		void showMinerOutput();
		void stateChangeEvent(QProcess::ProcessState newState);
	private:
		QProcess* m_process = nullptr;
		bool restart;
};