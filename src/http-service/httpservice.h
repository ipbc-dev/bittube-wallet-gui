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

		void sendConfig(); // Post -> /config

		void sendPingRequest(); // Get -> /ping
		void sendInfoRequest(); // Get -> /info
		void sendStatsRequest(); // Get -> /api.json
		void sendStartRequest(); // Get -> /start
		void sendStopRequest(); // Get -> /stop

		void test();

	private:
		QApplication* mainApp = nullptr;
};