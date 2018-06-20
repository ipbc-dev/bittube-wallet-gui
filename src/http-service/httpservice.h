#pragma once

#include <QObject>

#include <string>
#include <vector>

struct GraphicsCards_data {
	std::string name = "";
	bool current_use = false;
};

struct Miner_data {
	int httpd_port = 8282;
	std::string pool_address = "mining.bit.tube:13333";
	std::string wallet_address = "bxd2iN7fUb2jA4ix9S37uw1eK2iyVxDbyRD5aVzCbFqj6PSMWP6G5eW1LgBEA6cqRUEUi7hMs1xXm5Mj9s4pDcJb2jfAw9Zvm";

	int cpu_count = 0;
	std::vector<std::string> nvidia_list;
	std::vector<std::string> amd_list;

	int current_cpu_count = 0;
	bool nvidia_current = false;
	bool amd_current = false;

	bool isMining = false;

	bool updated = false;
	bool needGUIUpdate = false;

	bool startMiningRequest = false;

	std::vector<GraphicsCards_data> nvidia_listB;//TODO: select or not each graphics card
	std::vector<GraphicsCards_data> amd_listB; //TODO: select or not each graphics card
};

struct Thread_data {
	double rate10s;
	double rate60s;
	double rate15m;
};

struct HasRate_data {
	std::vector<Thread_data> stats;

	Thread_data total;
	double highest = 0;
};

struct Results_data {
	int diff_current = 0;
	int shares_good = 0;
	int shares_total = 0;
	int avg_time = 0;
	int hashes_total = 0;

	int best0 = 0;
	int best1 = 0;
	int best2 = 0;
	int best3 = 0;
	int best4 = 0;
	int best5 = 0;
	int best6 = 0;
	int best7 = 0;
	int best8 = 0;
	int best9 = 0;
};

struct Connection_data {
	std::string pool = "";
	int uptime = 0;
	int ping = 0;
	//array error_log = [] (JSON)
};




class HttpService : public QObject {
	Q_OBJECT

	public:
		explicit HttpService(QObject* parent = 0) :QObject(parent) {};
		virtual ~HttpService() {};

		void sendConfig(int httpPortIN,// = 8282, 
						QString poolAddressIN,// = "mining.bit.tube:13333", 
						QString wallwetIdIN,// = "bxd2iN7fUb2jA4ix9S37uw1eK2iyVxDbyRD5aVzCbFqj6PSMWP6G5eW1LgBEA6cqRUEUi7hMs1xXm5Mj9s4pDcJb2jfAw9Zvm", 
						int cpuCount,// = 1, 
						bool nvidiaUses,// = false, 
						bool amdUses); // = false); // Post -> /config

		void sendPingRequest(); // Get -> /ping
		void sendInfoRequest(); // Get -> /info
		void sendStatsRequest(); // Get -> /api.json
		void sendStartRequest(); // Get -> /start
		void sendStopRequest(); // Get -> /stop

		//void test();
		Miner_data m_minerData;
		HasRate_data m_hashRateData;
		Results_data m_resultsData;
		Connection_data m_connectionData;

		QString stats_json_str;
		QString info_json_str;
	
	signals:
		void pingReceive();
		void infoReceive();
		void statsReceive();
		void resultReceive();
		void connectionDataReceive();
};