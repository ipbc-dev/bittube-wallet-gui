#pragma once

#include <QObject>

#include <string>
#include <vector>

struct Miner_data {
	int httpd_port = 8282;
	std::string pool_address = "mining.bit.tube:13333";
	std::string wallet_address = "bxd2iN7fUb2jA4ix9S37uw1eK2iyVxDbyRD5aVzCbFqj6PSMWP6G5eW1LgBEA6cqRUEUi7hMs1xXm5Mj9s4pDcJb2jfAw9Zvm";

	int cpu_count = -1;
	std::vector<std::string> nvidia_list;
	std::vector<std::string> amd_list;

	int current_cpu_count = -1;
	bool nvidia_current = false;
	bool amd_current = false;

	bool isMining = false;

	bool updated = false;
	bool needGUIUpdate = false;

};



class HttpService : public QObject {
	Q_OBJECT

	public:
		explicit HttpService(QObject* parent = 0) :QObject(parent) {};
		virtual ~HttpService() {};

		void sendConfig(); // Post -> /config

		void sendPingRequest(); // Get -> /ping
		void sendInfoRequest(); // Get -> /info
		void sendStatsRequest(); // Get -> /api.json
		void sendStartRequest(); // Get -> /start
		void sendStopRequest(); // Get -> /stop

		void test();

	private:
		Miner_data m_minerData;
};