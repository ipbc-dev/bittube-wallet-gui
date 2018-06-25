#include "httpservice.h"

#include <iostream>

#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QUrl>
#include <QUrlQuery>


#include <QTime>
#include <QCoreApplication>
#include <QEventLoop>

/*
 * Description: ...
 */
void HttpService::sendConfig(int httpPortIN, QString poolAddressIN, QString wallwetIdIN, int cpuCount, bool nvidiaUses, bool amdUses, bool gpuUses, QString gpuListIN) { // Post -> /config
	//std::cout << "Sending [Configuration] Request" << std::endl;

	QUrlQuery params;

	std::cout << "   +++--- cpuCount = " << cpuCount << std::endl;
	params.addQueryItem("cpu_count", QString::number(cpuCount));
	if (nvidiaUses) {
		params.addQueryItem("nvidia_list", "true");
	} else {
		params.addQueryItem("nvidia_list", "false");
	}

	if (amdUses) {
		params.addQueryItem("amd_list", "true");
	} else {
		params.addQueryItem("amd_list", "false");
	}

	if (gpuUses) {
		params.addQueryItem("gpu_active", "true");
	} else {
		params.addQueryItem("gpu_active", "false");
	}

	if(httpPortIN > 0) {
		params.addQueryItem("httpd_port", QString::number(httpPortIN));
	}

	std::cout << "   +++--- poolAddress = " << poolAddressIN.toStdString() << std::endl;
	if (!poolAddressIN.isNull() and !poolAddressIN.isEmpty()) {
		params.addQueryItem("pool_address", QString(poolAddressIN));
	}

	std::cout << "   +++--- address = " << wallwetIdIN.toStdString() << std::endl;
	if (!wallwetIdIN.isNull() and !wallwetIdIN.isEmpty()) {
		params.addQueryItem("wallet_address", QString(wallwetIdIN));
	}

	std::cout << "   +++--- gpuList = " << gpuListIN.toStdString() << std::endl;
	if (!gpuListIN.isNull() and !gpuListIN.isEmpty()) {
		params.addQueryItem("gpu_list", QString(gpuListIN));
	}else {
		params.addQueryItem("gpu_list", QString(""));
	}


	QUrl url("http://localhost:8282/config");
	QNetworkRequest request(url);
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

	QNetworkAccessManager* manager = new QNetworkAccessManager(this);
	QNetworkReply* reply = manager->post(request, params.query(QUrl::FullyEncoded).toUtf8());

	connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
		[=](QNetworkReply::NetworkError code) {
			//std::cout << "-------------------------------------------------------------------" << std::endl;
			//std::cout << "[Configuration] Request: we found an network error with code: " << code << std::endl;
			//std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});


	connect(reply, &QNetworkReply::finished, 
		[=]() {
			if(reply->error() == QNetworkReply::NoError) {
				QByteArray response_data = reply->readAll();
				//std::cout << "-------------------------------------------------------------------" << std::endl;
				//std::cout << "[Configuration] Request: \n   - Ok, Server response : " << response_data.toStdString() << std::endl;
				//std::cout << "-------------------------------------------------------------------" << std::endl;

				if(m_minerData.startMiningRequest) {
					QTime dieTime= QTime::currentTime().addSecs(1);
					while (QTime::currentTime() < dieTime) {
						QCoreApplication::processEvents(QEventLoop::AllEvents, 100);
					}
					sendPingRequest();
				}
			}

			manager->deleteLater();
			reply->deleteLater();
		});
}

/*
 * Description: ...
 */
void HttpService::sendPingRequest() { // Get -> /ping
	//std::cout << "Sending [ping] Request" << std::endl;

	QUrl url("http://localhost:8282/ping");
	QNetworkRequest request(url);
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

	QNetworkAccessManager* manager = new QNetworkAccessManager(this);
	QNetworkReply* reply = manager->get(request);

	connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
		[=](QNetworkReply::NetworkError code) {
			//std::cout << "-------------------------------------------------------------------" << std::endl;
			//std::cout << "[Ping] Request: we found an network error with code: " << code << std::endl;
			//std::cout << "-------------------------------------------------------------------" << std::endl;
			if(m_minerData.startMiningRequest) {
				sendPingRequest();
			}

			manager->deleteLater();
			reply->deleteLater();
		});

	
	connect(reply, &QNetworkReply::finished, 
		[=]() {
			if(reply->error() == QNetworkReply::NoError) {
				QByteArray response_data = reply->readAll();
				//std::cout << "-------------------------------------------------------------------" << std::endl;
				//std::cout << "[Ping] Request: \n   - Ok, Server response : " << response_data.toStdString() << std::endl;
				//std::cout << "-------------------------------------------------------------------" << std::endl;
				if(m_minerData.startMiningRequest) {
					sendStartRequest();
				}
			}
			manager->deleteLater();
			reply->deleteLater();
		});
}

/*
 * Description: ...
 */
void HttpService::sendInfoRequest() { // Get -> /info
	//std::cout << "Sending [Info] Request" << std::endl;

	QUrl url("http://localhost:8282/info");
	QNetworkRequest request(url);
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

	QNetworkAccessManager* manager = new QNetworkAccessManager(this);
	QNetworkReply* reply = manager->get(request);

	connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
		[=](QNetworkReply::NetworkError code) {
			//std::cout << "-------------------------------------------------------------------" << std::endl;
			//std::cout << "[Info] Request: we found an network error with code: " << code << std::endl;
			//std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});

	
	connect(reply, &QNetworkReply::finished, 
		[=]() {
			if(reply->error() == QNetworkReply::NoError) {
				QByteArray response_data = reply->readAll();
				//std::cout << "-------------------------------------------------------------------" << std::endl;
				//std::cout << "[Info] Request: \n   - Ok, Server response : " << response_data.toStdString() << std::endl;
				//std::cout << "-------------------------------------------------------------------" << std::endl;
				QJsonParseError error;
				QJsonDocument json = QJsonDocument::fromJson(response_data, &error);

				if (json.isNull() || json.isEmpty()){
					std::cout << "[Info] Request: Error parsing response data. \n   - JSON fail:  " << error.errorString().toStdString() << error.offset;
				} else {
					if(json.isObject()) {
						info_json_str = QString::fromStdString(json.toJson().toStdString());

						// //FIXME: delete this ----
						// //std::cout << "   - cpu_count: " << m_minerData.cpu_count << std::endl;
						// //std::cout << "   - current_cpu_count: " << m_minerData.current_cpu_count << std::endl;
						// //std::cout << "   - nvidia_list: " << std::endl;
						// //for (uint i = 0; i < m_minerData.nvidia_list.size(); ++i) {
						// //	std::cout << "      " << m_minerData.nvidia_list[i] << std::endl;
						// //}
						// //std::cout << "   - amd_list: " << std::endl;
						// //for (uint i = 0; i < m_minerData.amd_list.size(); ++i) {
						// //	std::cout << "      " << m_minerData.amd_list[i] << std::endl;
						// //}
						// //std::cout << "   - nvidia_current: " << m_minerData.nvidia_current << std::endl;
						// //std::cout << "   - amd_current: " << m_minerData.amd_current << std::endl;
						// //std::cout << "   - httpd_port: " << m_minerData.httpd_port << std::endl;
						// //std::cout << "   - pool_address: " << m_minerData.pool_address << std::endl;
						// //std::cout << "   - wallet_address: " << m_minerData.wallet_address << std::endl;
						// //std::cout << "   - isMining: " << m_minerData.isMining << std::endl;
						// //-----------------------


						// QJsonObject jsonObj(json.object());
						// if (jsonObj.contains("cpu_count")) {
						// 	//std::cout << "cpu count found" << std::endl;
						// 	int tmpValue = jsonObj.value("cpu_count").toInt();

						// 	if (tmpValue != m_minerData.cpu_count) {
						// 		m_minerData.cpu_count = tmpValue;
						// 		m_minerData.needGUIUpdate = true;
						// 	}
						// } else {
						// 	//std::cout << "cpu count not found" << std::endl;
						// 	//TODO: error handling
						// }

						// if (jsonObj.contains("current_cpu_count")) {
						// 	//std::cout << "current_cpu_count found" << std::endl;
						// 	int tmpValue = jsonObj.value("current_cpu_count").toInt();

						// 	if (tmpValue != m_minerData.current_cpu_count) {
						// 		m_minerData.current_cpu_count = tmpValue;
						// 		m_minerData.needGUIUpdate = true;
						// 	}
						// } else {
						// 	//std::cout << "current_cpu_count not found" << std::endl;
						// 	//TODO: error handling
						// }

						// if (jsonObj.contains("nvidia_list")) {
						// 	//std::cout << "nvidia_list found" << std::endl;

						// 	QJsonValue value = jsonObj.value("nvidia_list");
						// 	QJsonArray array = value.toArray();

						// 	if(m_minerData.nvidia_list.size() > 0) {
						// 		m_minerData.nvidia_list.clear();
						// 	}

						// 	foreach (const QJsonValue & val, array) {
						// 		//std::cout << "+++ " << val.toString().toStdString() << std::endl;
						// 		m_minerData.nvidia_list.push_back(val.toString().toStdString());
						// 	}

						// } else {
						// 	//std::cout << "nvidia_list not found" << std::endl;
						// 	//TODO: error handling
						// }

						// if (jsonObj.contains("amd_list")) {
						// 	//std::cout << "amd_list found" << std::endl;

						// 	QJsonValue value = jsonObj.value("amd_list");
						// 	QJsonArray array = value.toArray();

						// 	if(m_minerData.amd_list.size() > 0) {
						// 		m_minerData.amd_list.clear();
						// 	}

						// 	foreach (const QJsonValue & val, array) {
						// 		//std::cout << "+++ " << val.toString().toStdString() << std::endl;
						// 		m_minerData.amd_list.push_back(val.toString().toStdString());
						// 	}

						// } else {
						// 	//std::cout << "amd_list not found" << std::endl;
						// 	//TODO: error handling
						// }

						// if (jsonObj.contains("nvidia_current")) {
						// 	//std::cout << "nvidia_current found" << std::endl;
						// 	bool tmpValue = jsonObj.value("nvidia_current").toBool();
						// 	if (tmpValue != m_minerData.nvidia_current) {
						// 		m_minerData.nvidia_current = tmpValue;
						// 		m_minerData.needGUIUpdate = true;
						// 	}
						// } else {
						// 	//std::cout << "nvidia_current not found" << std::endl;
						// 	//TODO: error handling
						// }

						// if (jsonObj.contains("amd_current")) {
						// 	//std::cout << "amd_current found" << std::endl;
						// 	bool tmpValue = jsonObj.value("amd_current").toBool();
						// 	if (tmpValue != m_minerData.amd_current) {
						// 		m_minerData.amd_current = tmpValue;
						// 		m_minerData.needGUIUpdate = true;
						// 	}
						// } else {
						// 	//std::cout << "amd_current not found" << std::endl;
						// 	//TODO: error handling
						// }

						// if (jsonObj.contains("httpd_port")) {
						// 	//std::cout << "httpd_port found" << std::endl;
						// 	int tmpValue = jsonObj.value("httpd_port").toInt();

						// 	if (tmpValue != m_minerData.httpd_port) {
						// 		m_minerData.httpd_port = tmpValue;
						// 		m_minerData.needGUIUpdate = true;
						// 	}
						// } else {
						// 	//std::cout << "httpd_port not found" << std::endl;
						// 	//TODO: error handling
						// }

						// if (jsonObj.contains("pool_address")) {
						// 	//std::cout << "pool_address found" << std::endl;
						// 	std::string tmpValue = jsonObj.value("pool_address").toString().toStdString();

						// 	if (tmpValue != m_minerData.pool_address) {
						// 		m_minerData.pool_address = tmpValue;
						// 		m_minerData.needGUIUpdate = true;
						// 	}
						// } else {
						// 	//std::cout << "pool_address not found" << std::endl;
						// 	//TODO: error handling
						// }

						// if (jsonObj.contains("wallet_address")) {
						// 	//std::cout << "wallet_address found" << std::endl;
						// 	std::string tmpValue = jsonObj.value("wallet_address").toString().toStdString();

						// 	if (tmpValue != m_minerData.wallet_address) {
						// 		m_minerData.wallet_address = tmpValue;
						// 		m_minerData.needGUIUpdate = true;
						// 	}
						// } else {
						// 	//std::cout << "wallet_address not found" << std::endl;
						// 	//TODO: error handling
						// }

						// if (jsonObj.contains("isMining")) {
						// 	//std::cout << "isMining found" << std::endl;
						// 	bool tmpValue = jsonObj.value("isMining").toBool();
						// 	if (tmpValue != m_minerData.isMining) {
						// 		m_minerData.isMining = tmpValue;
						// 		m_minerData.needGUIUpdate = true;
						// 	}
						// } else {
						// 	//std::cout << "isMining not found" << std::endl;
						// 	//TODO: error handling
						// }

						// if(m_minerData.needGUIUpdate) {
						// 	//FIXME: delete this ----
						// 	//std::cout << "   - cpu_count: " << m_minerData.cpu_count << std::endl;
						// 	//std::cout << "   - current_cpu_count: " << m_minerData.current_cpu_count << std::endl;
						// 	//std::cout << "   - nvidia_list: " << std::endl;
						// 	//for (uint i = 0; i < m_minerData.nvidia_list.size(); ++i) {
						// 	//	std::cout << "      " << m_minerData.nvidia_list[i] << std::endl;
						// 	//}
						// 	//std::cout << "   - amd_list: " << std::endl;
						// 	//for (uint i = 0; i < m_minerData.amd_list.size(); ++i) {
						// 	//	std::cout << "      " << m_minerData.amd_list[i] << std::endl;
						// 	//}
						// 	//std::cout << "   - nvidia_current: " << m_minerData.nvidia_current << std::endl;
						// 	//std::cout << "   - amd_current: " << m_minerData.amd_current << std::endl;
						// 	//std::cout << "   - httpd_port: " << m_minerData.httpd_port << std::endl;
						// 	//std::cout << "   - pool_address: " << m_minerData.pool_address << std::endl;
						// 	//std::cout << "   - wallet_address: " << m_minerData.wallet_address << std::endl;
						// 	//std::cout << "   - isMining: " << m_minerData.isMining << std::endl;
						// 	//-----------------------
						// 	emit infoReceive();
						// } else {
						// 	std::cout << "   - nothing change!!!" << std::endl;
						// }
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
	//std::cout << "Sending [Stats] Request" << std::endl;

	QUrl url("http://localhost:8282/api.json");
	QNetworkRequest request(url);
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

	QNetworkAccessManager* manager = new QNetworkAccessManager(this);
	QNetworkReply* reply = manager->get(request);

	connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
		[=](QNetworkReply::NetworkError code) {
			//std::cout << "-------------------------------------------------------------------" << std::endl;
			//std::cout << "[Stats] Request: we found an network error with code: " << code << std::endl;
			//std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});

	
	connect(reply, &QNetworkReply::finished, 
		[=]() {
			if(reply->error() == QNetworkReply::NoError) {
				QByteArray response_data = reply->readAll();
				//std::cout << "-------------------------------------------------------------------" << std::endl;
				//std::cout << "[Stats] Request: \n   - Ok, Server response : " << response_data.toStdString() << std::endl;
				//std::cout << "-------------------------------------------------------------------" << std::endl;

				QJsonParseError error;
				QJsonDocument json = QJsonDocument::fromJson(response_data, &error);

			if (json.isNull() || json.isEmpty()){
				std::cout << "[Stats] Request: Error parsing response data. \n   - JSON fail:  " << error.errorString().toStdString() << error.offset;
			} else {
				if(json.isObject()) {

					stats_json_str = QString::fromStdString(json.toJson(QJsonDocument::Compact).toStdString());
					
					// QJsonObject jsonObj(json.object());
					// if (jsonObj.contains("hashrate")) {
					// 	std::cout << "hashrate found" << std::endl;

					// 		//FIXME: delete this ----
					// 		//std::cout << "   - Threads[" << m_hashRateData.stats.size() << "]: " << std::endl;
					// 		//for (uint i = 0; i < m_hashRateData.stats.size(); ++i) {
					// 		//	std::cout << "      - [" << i << "]: " << m_hashRateData.stats[i].rate10s << std::endl;
					// 		//	std::cout << "      - [" << i << "]: " << m_hashRateData.stats[i].rate60s << std::endl;
					// 		//	std::cout << "      - [" << i << "]: " << m_hashRateData.stats[i].rate15m << std::endl;
					// 		//}
					// 		//std::cout << "   - total: [" << m_hashRateData.total.rate10s  << ", " << m_hashRateData.total.rate60s << ", " << m_hashRateData.total.rate15m << "]: " << std::endl;
					// 		//std::cout << "   - highest: " << m_hashRateData.highest << std::endl;
					// 		//-----------------------

					// 		QJsonObject jsonObj002(jsonObj.value("hashrate").toObject());
							
					// 		//---
					// 		if(jsonObj002.contains("threads")) {
					// 			//std::cout << "threads (hashrate) found" << std::endl;
					// 			QJsonValue value = jsonObj002.value("threads");
					// 			QJsonArray array = value.toArray();

					// 			if (m_hashRateData.stats.size() <= 0)
					// 			if (array.size() != m_hashRateData.stats.size()) {
					// 				m_hashRateData.stats.clear();
					// 			}

					// 			foreach (const QJsonValue & val, array) {
					// 				QJsonArray arrayTmp = val.toArray();
					// 				if (arrayTmp.size() == 3) {
					// 					double value10s = arrayTmp[0].toDouble();
					// 					double value60s = arrayTmp[1].toDouble();
					// 					double value15m = arrayTmp[2].toDouble();

					// 					Thread_data dataTmp = {.rate10s = value10s, .rate60s = value60s, .rate15m = value15m};
					// 					dataTmp.rate10s = value10s;
					// 					dataTmp.rate60s = value60s;
					// 					dataTmp.rate15m = value15m;
					// 					m_hashRateData.stats.push_back(dataTmp);
					// 				}
					// 			}
					// 		}

					// 		//---
					// 		if(jsonObj002.contains("total")) {
					// 			//std::cout << "total (hashrate) found" << std::endl;
					// 			QJsonValue value = jsonObj002.value("total");
					// 			QJsonArray array = value.toArray();

					// 			m_hashRateData.total.rate10s = array[0].toDouble();
					// 			m_hashRateData.total.rate60s = array[1].toDouble();
					// 			m_hashRateData.total.rate15m = array[2].toDouble();
					// 		}

					// 		//---
					// 		if(jsonObj002.contains("highest")) {
					// 			//std::cout << "highest (hashrate) found" << std::endl;

					// 			m_hashRateData.highest = jsonObj002.value("highest").toDouble();
					// 		}

					// 		//FIXME: delete this ----
					// 		//std::cout << "   - Threads[" << m_hashRateData.stats.size() << "]: " << std::endl;
					// 		//for (uint i = 0; i < m_hashRateData.stats.size(); ++i) {
					// 		//	std::cout << "      - [" << i << "]: " << m_hashRateData.stats[i].rate10s << std::endl;
					// 		//	std::cout << "      - [" << i << "]: " << m_hashRateData.stats[i].rate60s << std::endl;
					// 		//	std::cout << "      - [" << i << "]: " << m_hashRateData.stats[i].rate15m << std::endl;
					// 		//}
					// 		//std::cout << "   - total: [" << m_hashRateData.total.rate10s  << ", " << m_hashRateData.total.rate60s << ", " << m_hashRateData.total.rate15m << "]: " << std::endl;
					// 		//std::cout << "   - highest: " << m_hashRateData.highest << std::endl;
					// 		//-----------------------

					// 		emit statsReceive();
					// 	}

					// 	if (jsonObj.contains("results")) {
					// 		//TODO: parse error_log atribute
					// 		std::cout << "results found" << std::endl;

					// 		//FIXME: delete this ----
					// 		//std::cout << "   - diff_current: " << m_resultsData.diff_current << std::endl;
					// 		//std::cout << "   - shares_good: " << m_resultsData.shares_good << std::endl;
					// 		//std::cout << "   - shares_total: " << m_resultsData.shares_total << std::endl;
					// 		//std::cout << "   - avg_time: " << m_resultsData.avg_time << std::endl;
					// 		//std::cout << "   - hashes_total: " << m_resultsData.hashes_total << std::endl;

					// 		//std::cout << "   - best0: " << m_resultsData.best0 << std::endl;
					// 		//std::cout << "   - best1: " << m_resultsData.best1 << std::endl;
					// 		//std::cout << "   - best2: " << m_resultsData.best2 << std::endl;
					// 		//std::cout << "   - best3: " << m_resultsData.best3 << std::endl;
					// 		//std::cout << "   - best4: " << m_resultsData.best4 << std::endl;
					// 		//std::cout << "   - best5: " << m_resultsData.best5 << std::endl;
					// 		//std::cout << "   - best6: " << m_resultsData.best6 << std::endl;
					// 		//std::cout << "   - best7: " << m_resultsData.best7 << std::endl;
					// 		//std::cout << "   - best8: " << m_resultsData.best8 << std::endl;
					// 		//std::cout << "   - best9: " << m_resultsData.best9 << std::endl;
					// 		//-----------------------

					// 		QJsonObject jsonObj002(jsonObj.value("results").toObject());
					// 		if(jsonObj002.contains("diff_current")) {
					// 			//std::cout << "diff_current [results] found" << std::endl;
					// 			m_resultsData.diff_current = jsonObj002.value("diff_current").toInt();
					// 		}

					// 		if(jsonObj002.contains("shares_good")) {
					// 			//std::cout << "shares_good [results] found" << std::endl;
					// 			m_resultsData.shares_good = jsonObj002.value("shares_good").toInt();
					// 		}

					// 		if(jsonObj002.contains("shares_total")) {
					// 			//std::cout << "shares_total [results] found" << std::endl;
					// 			m_resultsData.shares_total = jsonObj002.value("shares_total").toInt();
					// 		}

					// 		if(jsonObj002.contains("avg_time")) {
					// 			//std::cout << "avg_time [results] found" << std::endl;
					// 			m_resultsData.avg_time = jsonObj002.value("avg_time").toInt();
					// 		}

					// 		if(jsonObj002.contains("hashes_total")) {
					// 			//std::cout << "hashes_total [results] found" << std::endl;
					// 			m_resultsData.hashes_total = jsonObj002.value("hashes_total").toInt();
					// 		}

					// 		if(jsonObj002.contains("best")) {
					// 			//std::cout << "best [results] found" << std::endl;
					// 			QJsonValue value = jsonObj002.value("best");
					// 			QJsonArray array = value.toArray();

					// 			for(int i = 0; i < array.size(); ++i){
					// 				switch(i) {
					// 					case 0: 
					// 						m_resultsData.best0 = array[i].toInt();
					// 						break;
					// 					case 1:
					// 						m_resultsData.best1 = array[i].toInt();
					// 						break;
					// 					case 2:
					// 						m_resultsData.best2 = array[i].toInt();
					// 						break;
					// 					case 3:
					// 						m_resultsData.best3 = array[i].toInt();
					// 						break;
					// 					case 4:
					// 						m_resultsData.best4 = array[i].toInt();
					// 						break;
					// 					case 5:
					// 						m_resultsData.best5 = array[i].toInt();
					// 						break;
					// 					case 6: 
					// 						m_resultsData.best6 = array[i].toInt();
					// 						break;
					// 					case 7:
					// 						m_resultsData.best7 = array[i].toInt();
					// 						break;
					// 					case 8:
					// 						m_resultsData.best8 = array[i].toInt();
					// 						break;
					// 					case 9:
					// 						m_resultsData.best9 = array[i].toInt();
					// 						break;
					// 					default:
					// 						break;
					// 				}
					// 			}
					// 		}

					// 		//FIXME: delete this ----
					// 		//std::cout << "   - diff_current: " << m_resultsData.diff_current << std::endl;
					// 		//std::cout << "   - shares_good: " << m_resultsData.shares_good << std::endl;
					// 		//std::cout << "   - shares_total: " << m_resultsData.shares_total << std::endl;
					// 		//std::cout << "   - avg_time: " << m_resultsData.avg_time << std::endl;
					// 		//std::cout << "   - hashes_total: " << m_resultsData.hashes_total << std::endl;

					// 		//std::cout << "   - best0: " << m_resultsData.best0 << std::endl;
					// 		//std::cout << "   - best1: " << m_resultsData.best1 << std::endl;
					// 		//std::cout << "   - best2: " << m_resultsData.best2 << std::endl;
					// 		//std::cout << "   - best3: " << m_resultsData.best3 << std::endl;
					// 		//std::cout << "   - best4: " << m_resultsData.best4 << std::endl;
					// 		//std::cout << "   - best5: " << m_resultsData.best5 << std::endl;
					// 		//std::cout << "   - best6: " << m_resultsData.best6 << std::endl;
					// 		//std::cout << "   - best7: " << m_resultsData.best7 << std::endl;
					// 		//std::cout << "   - best8: " << m_resultsData.best8 << std::endl;
					// 		//std::cout << "   - best9: " << m_resultsData.best9 << std::endl;
					// 		//------------------------

					// 		emit resultReceive();
					// 	}

					// 	if (jsonObj.contains("connection")) {
					// 		//TODO: parse error_log atribute
					// 		//std::cout << "connection found" << std::endl;

					// 		//FIXME: delete this ----
					// 		//std::cout << "   - pool: " << m_connectionData.pool << std::endl;
					// 		//std::cout << "   - uptime: " << m_connectionData.uptime << std::endl;
					// 		//std::cout << "   - ping: " << m_connectionData.ping << std::endl;
					// 		//-----------------------


					// 		QJsonObject jsonObj002(jsonObj.value("connection").toObject());
					// 		if(jsonObj002.contains("pool")) {
					// 			m_connectionData.pool = jsonObj002.value("pool").toString().toStdString();
					// 		}

					// 		if(jsonObj002.contains("uptime")) {
					// 			m_connectionData.uptime = jsonObj002.value("uptime").toInt();
					// 		}

					// 		if(jsonObj002.contains("ping")) {
					// 			m_connectionData.ping = jsonObj002.value("ping").toInt();
					// 		}



					// 		//FIXME: delete this ----
					// 		//std::cout << "   - pool: " << m_connectionData.pool << std::endl;
					// 		//std::cout << "   - uptime: " << m_connectionData.uptime << std::endl;
					// 		//std::cout << "   - ping: " << m_connectionData.ping << std::endl;
					// 		//-----------------------
					// 		emit connectionDataReceive();
					// 	}
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
void HttpService::sendStartRequest() { // Get -> /start
	//std::cout << "Sending [Start] Request" << std::endl;

	QUrl url("http://localhost:8282/start");
	QNetworkRequest request(url);
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

	QNetworkAccessManager* manager = new QNetworkAccessManager(this);
	QNetworkReply* reply = manager->get(request);

	connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
		[=](QNetworkReply::NetworkError code) {
			//std::cout << "-------------------------------------------------------------------" << std::endl;
			//std::cout << "[Start] Request: we found an network error with code: " << code << std::endl;
			//std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});

	
	connect(reply, &QNetworkReply::finished, 
		[=]() {
			if(reply->error() == QNetworkReply::NoError) {
				QByteArray response_data = reply->readAll();
				//std::cout << "-------------------------------------------------------------------" << std::endl;
				//std::cout << "[Start] Request: \n   - Ok, Server response : " << response_data.toStdString() << std::endl;
				//std::cout << "-------------------------------------------------------------------" << std::endl;
				if(m_minerData.startMiningRequest) {
					m_minerData.startMiningRequest = false;
				}
			}
			manager->deleteLater();
			reply->deleteLater();
		});
}

/*
 * Description: ...
 */
void HttpService::sendStopRequest() { // Get -> /stop
	//std::cout << "Sending [Stop] Request" << std::endl;

	QUrl url("http://localhost:8282/stop");
	QNetworkRequest request(url);
	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

	QNetworkAccessManager* manager = new QNetworkAccessManager(this);
	QNetworkReply* reply = manager->get(request);

	connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
		[=](QNetworkReply::NetworkError code) {
			//std::cout << "-------------------------------------------------------------------" << std::endl;
			//std::cout << "[Stop] Request: we found an network error with code: " << code << std::endl;
			//std::cout << "-------------------------------------------------------------------" << std::endl;
			manager->deleteLater();
			reply->deleteLater();
		});

	
	connect(reply, &QNetworkReply::finished, 
		[=]() {
			if(reply->error() == QNetworkReply::NoError) {
				QByteArray response_data = reply->readAll();
				//std::cout << "-------------------------------------------------------------------" << std::endl;
				//std::cout << "[Stop] Request: \n   - Ok, Server response : " << response_data.toStdString() << std::endl;
				//std::cout << "-------------------------------------------------------------------" << std::endl;
			}
			manager->deleteLater();
			reply->deleteLater();
		});
}


//------------------------------------------------------------------------------------------

/*
 * Description: ...
 */
// void HttpService::test() {

// 	std::cout << "testing post service" << std::endl;

// 	QByteArray jsonDocument("{}");

// 	//QUrl url("http://ip.jsontest.com/");
// 	QUrl url("http://127.0.0.1:8282/info");
// 	QNetworkRequest request(url);
// 	request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

// 	QNetworkAccessManager* manager = new QNetworkAccessManager(this);
// 	//QNetworkReply* reply = manager.post(request, jsonDocument);
// 	QNetworkReply* reply = manager->get(request); 

// 	connect(reply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
// 	[=](QNetworkReply::NetworkError code) {
// 		std::cout << "we found an network error with code: " << code << std::endl;
// 		manager->deleteLater();
// 		reply->deleteLater();
// 	});

	
// 	connect(reply, &QNetworkReply::finished, 
// 	[=]() {
// 		QByteArray response_data = reply->readAll();
// 		std::cout << "Ok, Server response : " << response_data.toStdString() << std::endl;
// 		manager->deleteLater();
// 		reply->deleteLater();
// 	});
	

	

// 	//while((reply->error() == QNetworkReply::NoError) || !reply->isFinished()) {//FIXME: change this for connecting signals and slots
// 	//	mainApp->processEvents();
// 	//}

// 	//if(reply->error() == QNetworkReply::NoError){
// 	//	QByteArray response_data = reply->readAll();

// 	//	std::cout << "Ok, Server response : " << response_data.toStdString() << std::endl;
// 	//}else{
// 	//	std::cout << "Error, network reply : " << reply->error() << std::endl;
// 	//}
// }