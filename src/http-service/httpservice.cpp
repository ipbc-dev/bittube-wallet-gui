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
void HttpService::sendConfig() { // Post -> /config
	std::cout << "Sending [Configuration] Request" << std::endl;

	QByteArray jsonDocument("{}"); //TODO: generate config object

	QUrl url("http://localhost:8282/config");
	QNetworkRequest request(url);
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

	QNetworkAccessManager* manager = new QNetworkAccessManager(this);
	QNetworkReply* reply = manager->post(request, jsonDocument);

	connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
		[=](QNetworkReply::NetworkError code) {
			std::cout << "-------------------------------------------------------------------" << std::endl;
			std::cout << "[Configuration] Request: we found an network error with code: " << code << std::endl;
			std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});

	
	connect(reply, &QNetworkReply::finished, 
		[=]() {
			QByteArray response_data = reply->readAll();
			std::cout << "-------------------------------------------------------------------" << std::endl;
			std::cout << "[Configuration] Request: \n   - Ok, Server response : " << response_data.toStdString() << std::endl;
			std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});
}

/*
 * Description: ...
 */
void HttpService::sendPingRequest() { // Get -> /ping
	std::cout << "Sending [ping] Request" << std::endl;

	QUrl url("http://localhost:8282/ping");
	QNetworkRequest request(url);
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

		QNetworkAccessManager* manager = new QNetworkAccessManager(this);
	QNetworkReply* reply = manager->get(request);

	connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
		[=](QNetworkReply::NetworkError code) {
			std::cout << "-------------------------------------------------------------------" << std::endl;
			std::cout << "[Ping] Request: we found an network error with code: " << code << std::endl;
			std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});

	
	connect(reply, &QNetworkReply::finished, 
		[=]() {
			QByteArray response_data = reply->readAll();
			std::cout << "-------------------------------------------------------------------" << std::endl;
			std::cout << "[Ping] Request: \n   - Ok, Server response : " << response_data.toStdString() << std::endl;
			std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});
}

/*
 * Description: ...
 */
void HttpService::sendInfoRequest() { // Get -> /info
	std::cout << "Sending [Info] Request" << std::endl;

	QUrl url("http://localhost:8282/info");
	QNetworkRequest request(url);
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

	QNetworkAccessManager* manager = new QNetworkAccessManager(this);
	QNetworkReply* reply = manager->get(request);

	connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
		[=](QNetworkReply::NetworkError code) {
			std::cout << "-------------------------------------------------------------------" << std::endl;
			std::cout << "[Info] Request: we found an network error with code: " << code << std::endl;
			std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});

	
	connect(reply, &QNetworkReply::finished, 
		[=]() {
			QByteArray response_data = reply->readAll();
			std::cout << "-------------------------------------------------------------------" << std::endl;
			std::cout << "[Info] Request: \n   - Ok, Server response : " << response_data.toStdString() << std::endl;
			std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});
}

/*
 * Description: ...
 */
void HttpService::sendStatsRequest() { // Get -> /api.json
	std::cout << "Sending [Stats] Request" << std::endl;

	QUrl url("http://localhost:8282/api.json");
	QNetworkRequest request(url);
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

	QNetworkAccessManager* manager = new QNetworkAccessManager(this);
	QNetworkReply* reply = manager->get(request);

	connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
		[=](QNetworkReply::NetworkError code) {
			std::cout << "-------------------------------------------------------------------" << std::endl;
			std::cout << "[Stats] Request: we found an network error with code: " << code << std::endl;
			std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});

	
	connect(reply, &QNetworkReply::finished, 
		[=]() {
			QByteArray response_data = reply->readAll();
			std::cout << "-------------------------------------------------------------------" << std::endl;
			std::cout << "[Stats] Request: \n   - Ok, Server response : " << response_data.toStdString() << std::endl;
			std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});
}

/*
 * Description: ...
 */
void HttpService::sendStartRequest() { // Get -> /start
	std::cout << "Sending [Start] Request" << std::endl;

	QUrl url("http://localhost:8282/start");
	QNetworkRequest request(url);
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

	QNetworkAccessManager* manager = new QNetworkAccessManager(this);
	QNetworkReply* reply = manager->get(request);

	connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
		[=](QNetworkReply::NetworkError code) {
			std::cout << "-------------------------------------------------------------------" << std::endl;
			std::cout << "[Start] Request: we found an network error with code: " << code << std::endl;
			std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});

	
	connect(reply, &QNetworkReply::finished, 
		[=]() {
			QByteArray response_data = reply->readAll();
			std::cout << "-------------------------------------------------------------------" << std::endl;
			std::cout << "[Start] Request: \n   - Ok, Server response : " << response_data.toStdString() << std::endl;
			std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});
}

/*
 * Description: ...
 */
void HttpService::sendStopRequest() { // Get -> /stop
	std::cout << "Sending [Stop] Request" << std::endl;

	QUrl url("http://localhost:8282/stop");
	QNetworkRequest request(url);
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

	QNetworkAccessManager* manager = new QNetworkAccessManager(this);
	QNetworkReply* reply = manager->get(request);

	connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
		[=](QNetworkReply::NetworkError code) {
			std::cout << "-------------------------------------------------------------------" << std::endl;
			std::cout << "[Stop] Request: we found an network error with code: " << code << std::endl;
			std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});

	
	connect(reply, &QNetworkReply::finished, 
		[=]() {
			QByteArray response_data = reply->readAll();
			std::cout << "-------------------------------------------------------------------" << std::endl;
			std::cout << "[Stop] Request: \n   - Ok, Server response : " << response_data.toStdString() << std::endl;
			std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});
}


//------------------------------------------------------------------------------------------

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

	QNetworkAccessManager* manager = new QNetworkAccessManager(this);
	//QNetworkReply* reply = manager.post(request, jsonDocument);
	QNetworkReply* reply = manager->get(request); 

	connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
	[=](QNetworkReply::NetworkError code) {
		std::cout << "we found an network error with code: " << code << std::endl;
		manager->deleteLater();
		reply->deleteLater();
	});

	
	connect(reply, &QNetworkReply::finished, 
	[=]() {
		QByteArray response_data = reply->readAll();
		std::cout << "Ok, Server response : " << response_data.toStdString() << std::endl;
		manager->deleteLater();
		reply->deleteLater();
	});
	

	

	//while((reply->error() == QNetworkReply::NoError) || !reply->isFinished()) {//FIXME: change this for connecting signals and slots
	//	mainApp->processEvents();
	//}

	//if(reply->error() == QNetworkReply::NoError){
	//	QByteArray response_data = reply->readAll();

	//	std::cout << "Ok, Server response : " << response_data.toStdString() << std::endl;
	//}else{
	//	std::cout << "Error, network reply : " << reply->error() << std::endl;
	//}
}