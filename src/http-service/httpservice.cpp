#include "httpservice.h"

#include <iostream>

#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonParseError>
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
			QJsonParseError error;
			QJsonDocument json = QJsonDocument::fromJson(response_data, &error);

			if (json.isNull() || json.isEmpty()){
				std::cout << "[Info] Request: Error parsing response data. \n   - JSON fail:  " << error.errorString().toStdString() << error.offset;
			} else {
				if(json.isObject()) {

					//FIXME: delete this ----
					std::cout << "   - cpu_count: " << m_minerData.cpu_count << std::endl;
					std::cout << "   - current_cpu_count: " << m_minerData.current_cpu_count << std::endl;
					std::cout << "   - nvidia_list: " << std::endl;
					for (uint i = 0; i < m_minerData.nvidia_list.size(); ++i) {
						std::cout << "      " << m_minerData.nvidia_list[i] << std::endl;
					}
					//TODO: show nvidia-list
					std::cout << "   - amd_list: " << std::endl;
					for (uint i = 0; i < m_minerData.amd_list.size(); ++i) {
						std::cout << "      " << m_minerData.amd_list[i] << std::endl;
					}
					//TODO: show amd list
					std::cout << "   - nvidia_current: " << m_minerData.nvidia_current << std::endl;
					std::cout << "   - amd_current: " << m_minerData.amd_current << std::endl;
					std::cout << "   - httpd_port: " << m_minerData.httpd_port << std::endl;
					std::cout << "   - pool_address: " << m_minerData.pool_address << std::endl;
					std::cout << "   - wallet_address: " << m_minerData.wallet_address << std::endl;
					std::cout << "   - isMining: " << m_minerData.isMining << std::endl;
					//-----------------------


					QJsonObject jsonObj(json.object());
					if (jsonObj.contains("cpu_count")) {
						std::cout << "cpu count found" << std::endl;
						int tmpValue = jsonObj.value("cpu_count").toInt();

						if (tmpValue != m_minerData.cpu_count) {
							m_minerData.cpu_count = tmpValue;
							m_minerData.needGUIUpdate = true;
						}
					} else {
						std::cout << "cpu count not found" << std::endl;
						//TODO: error handling
					}

					if (jsonObj.contains("current_cpu_count")) {
						std::cout << "current_cpu_count found" << std::endl;
						int tmpValue = jsonObj.value("current_cpu_count").toInt();

						if (tmpValue != m_minerData.current_cpu_count) {
							m_minerData.current_cpu_count = tmpValue;
							m_minerData.needGUIUpdate = true;
						}
					} else {
						std::cout << "current_cpu_count not found" << std::endl;
						//TODO: error handling
					}

					if (jsonObj.contains("nvidia_list")) {
						std::cout << "nvidia_list found" << std::endl;

						QJsonValue value = jsonObj.value("nvidia_list");
						QJsonArray array = value.toArray();

						if(m_minerData.nvidia_list.size() > 0) {
							m_minerData.nvidia_list.clear();
						}

						foreach (const QJsonValue & val, array) {
							std::cout << "+++ " << val.toString().toStdString() << std::endl;
							m_minerData.nvidia_list.push_back(val.toString().toStdString());
							//QJsonObject dataObj = val.toObject().value("data").toObject();
							//qDebug() << dataObj.value("enclosure_id").toString();
						}

					} else {
						std::cout << "nvidia_list not found" << std::endl;
						//TODO: error handling
					}

					if (jsonObj.contains("amd_list")) {
						std::cout << "amd_list found" << std::endl;

						QJsonValue value = jsonObj.value("amd_list");
						QJsonArray array = value.toArray();

						if(m_minerData.amd_list.size() > 0) {
							m_minerData.amd_list.clear();
						}

						foreach (const QJsonValue & val, array) {
							std::cout << "+++ " << val.toString().toStdString() << std::endl;
							m_minerData.amd_list.push_back(val.toString().toStdString());
							//QJsonObject dataObj = val.toObject().value("data").toObject();
							//qDebug() << dataObj.value("enclosure_id").toString();
						}

					} else {
						std::cout << "amd_list not found" << std::endl;
						//TODO: error handling
					}

					if (jsonObj.contains("nvidia_current")) {
						std::cout << "nvidia_current found" << std::endl;
						bool tmpValue = jsonObj.value("nvidia_current").toBool();
						if (tmpValue != m_minerData.nvidia_current) {
							m_minerData.nvidia_current = tmpValue;
							m_minerData.needGUIUpdate = true;
						}
					} else {
						std::cout << "nvidia_current not found" << std::endl;
						//TODO: error handling
					}

					if (jsonObj.contains("amd_current")) {
						std::cout << "amd_current found" << std::endl;
						bool tmpValue = jsonObj.value("amd_current").toBool();
						if (tmpValue != m_minerData.amd_current) {
							m_minerData.amd_current = tmpValue;
							m_minerData.needGUIUpdate = true;
						}
					} else {
						std::cout << "amd_current not found" << std::endl;
						//TODO: error handling
					}

					if (jsonObj.contains("httpd_port")) {
						std::cout << "httpd_port found" << std::endl;
						int tmpValue = jsonObj.value("httpd_port").toInt();

						if (tmpValue != m_minerData.httpd_port) {
							m_minerData.httpd_port = tmpValue;
							m_minerData.needGUIUpdate = true;
						}
					} else {
						std::cout << "httpd_port not found" << std::endl;
						//TODO: error handling
					}

					if (jsonObj.contains("pool_address")) {
						std::cout << "pool_address found" << std::endl;
						std::string tmpValue = jsonObj.value("pool_address").toString().toStdString();

						if (tmpValue != m_minerData.pool_address) {
							m_minerData.pool_address = tmpValue;
							m_minerData.needGUIUpdate = true;
						}
					} else {
						std::cout << "pool_address not found" << std::endl;
						//TODO: error handling
					}

					if (jsonObj.contains("wallet_address")) {
						std::cout << "wallet_address found" << std::endl;
						std::string tmpValue = jsonObj.value("wallet_address").toString().toStdString();

						if (tmpValue != m_minerData.wallet_address) {
							m_minerData.wallet_address = tmpValue;
							m_minerData.needGUIUpdate = true;
						}
					} else {
						std::cout << "wallet_address not found" << std::endl;
						//TODO: error handling
					}

					if (jsonObj.contains("isMining")) {
						std::cout << "isMining found" << std::endl;
						bool tmpValue = jsonObj.value("isMining").toBool();
						if (tmpValue != m_minerData.isMining) {
							m_minerData.isMining = tmpValue;
							m_minerData.needGUIUpdate = true;
						}
					} else {
						std::cout << "isMining not found" << std::endl;
						//TODO: error handling
					}

					if(m_minerData.needGUIUpdate) {


						//FIXME: delete this ----
						std::cout << "   - cpu_count: " << m_minerData.cpu_count << std::endl;
						std::cout << "   - current_cpu_count: " << m_minerData.current_cpu_count << std::endl;
						std::cout << "   - nvidia_list: " << std::endl;
						for (uint i = 0; i < m_minerData.nvidia_list.size(); ++i) {
							std::cout << "      " << m_minerData.nvidia_list[i] << std::endl;
						}
						//TODO: show nvidia-list
						std::cout << "   - amd_list: " << std::endl;
						for (uint i = 0; i < m_minerData.amd_list.size(); ++i) {
							std::cout << "      " << m_minerData.amd_list[i] << std::endl;
						}
						//TODO: show amd list
						std::cout << "   - nvidia_current: " << m_minerData.nvidia_current << std::endl;
						std::cout << "   - amd_current: " << m_minerData.amd_current << std::endl;
						std::cout << "   - httpd_port: " << m_minerData.httpd_port << std::endl;
						std::cout << "   - pool_address: " << m_minerData.pool_address << std::endl;
						std::cout << "   - wallet_address: " << m_minerData.wallet_address << std::endl;
						std::cout << "   - isMining: " << m_minerData.isMining << std::endl;
						//-----------------------
					} else {
						std::cout << "   - nothing change!!!" << std::endl;
					}
				}
			}

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