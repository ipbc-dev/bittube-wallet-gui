#pragma once

#include <QApplication>
#include <QObject>

class HttpService : public QObject {
	Q_OBJECT

	public:
		explicit HttpService(QObject* parent = 0) :QObject(parent) {};
		virtual ~HttpService() {};

		//void sendConfig();
		//void sendStatsRequest();

		void test(QApplication* app);

	
};