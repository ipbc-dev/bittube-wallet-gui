#pragma once

#include <QObject>

class QProcess;


class MinerManager : public QObject {
	Q_OBJECT

	public:
		explicit MinerManager(QObject* parent = 0);
		virtual ~MinerManager();

	private:
		QProcess* m_process = nullptr;
};