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
void HttpService::test(QApplication* app) {

	std::cout << "testing post service" << std::endl;

  QByteArray jsonDocument("{}");

  QUrl url("http://ip.jsontest.com/");
  QNetworkRequest request(url);
  request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

  QNetworkAccessManager manager;
  QNetworkReply* reply = manager.post(request, jsonDocument);

  while(!reply->isFinished()) {
    app->processEvents();
  }

  QByteArray response_data = reply->readAll();

  std::cout << "Ok, Server response : " << response_data.toStdString() << std::endl;
}