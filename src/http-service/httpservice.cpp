#include "httpservice.h"

#include <iostream>

#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QUrl>


/*
 * Description: ...
 */
void HttpService::sendConfig() {
	QByteArray jsonDocument("{}");

	QUrl url("http://localhost:8282/config");
	QNetworkRequest request(url);
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

	QNetworkAccessManager manager;
	QNetworkReply* reply = manager.post(request, jsonDocument);

	while(!reply->isFinished()) {
		mainApp->processEvents();
	}

	QByteArray response_data = reply->readAll();

	std::cout << "Ok, Server response : " << response_data.toStdString() << std::endl;
}

/*
 * Description: ...
 */
void HttpService::sendStatsRequest() {
	QByteArray jsonDocument("{}");

	QUrl url("http://localhost:8282/api.json");
	QNetworkRequest request(url);
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

	QNetworkAccessManager manager;
	QNetworkReply* reply = manager.get(request);

	while(!reply->isFinished()) {
		mainApp->processEvents();
	}

	QByteArray response_data = reply->readAll();

	std::cout << "Ok, Server response : " << response_data.toStdString() << std::endl;
}

/*
 * Description: ...
 */
void HttpService::test() {

	std::cout << "testing post service" << std::endl;

	QByteArray jsonDocument("{}");

	//QUrl url("http://ip.jsontest.com/");
	QUrl url("http://127.0.0.1:8282/info");
	QNetworkRequest request(url);
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

	QNetworkAccessManager manager;
	//QNetworkReply* reply = manager.post(request, jsonDocument);
	QNetworkReply* reply = manager.get(request); //post(request, jsonDocument);

	while(!reply->isFinished()) {
		mainApp->processEvents();
	}

	QByteArray response_data = reply->readAll();

	std::cout << "Ok, Server response : " << response_data.toStdString() << std::endl;
}