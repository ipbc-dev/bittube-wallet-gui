#pragma once

#include <QApplication>
#include <QObject>

class HttpService : public QObject {
	Q_OBJECT

	public:
		explicit HttpService(QApplication* appIN, QObject* parent = 0) :QObject(parent) {
			mainApp = appIN;
		};
		virtual ~HttpService() {};

		void sendConfig();
		void sendStatsRequest();

		void test();

	private:
		QApplication* mainApp = nullptr;
};