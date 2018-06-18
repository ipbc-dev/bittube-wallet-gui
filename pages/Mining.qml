// Copyright (c) 2014-2018, The Monero Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import "../components"
import moneroComponents.Wallet 1.0

Rectangle {
    id: root
    color: "transparent"
    property var currentHashRate: 0

    /* main layout */
    ColumnLayout {
        id: mainLayout
        anchors.margins: 40
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        // anchors.bottom: parent.bottom
        spacing: 20

        // solo
        ColumnLayout {
            id: soloBox
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 20

            Label {
                id: soloTitleLabel
                fontSize: 24
                text: qsTr("BitTube Miner") + translationManager.emptyString
            }

            Label {
                id: soloLocalDaemonsLabel
                fontSize: 18
                color: "#D02020"
                text: qsTr("(only available for local daemons)")
                visible: !walletManager.isDaemonLocal(appWindow.currentDaemonAddress)
            }
            
            Label {
                id: soloSyncedLabel
                fontSize: 18
                color: "#D02020"
                text: qsTr("Your daemon must be synchronized before you can start mining")
                visible: walletManager.isDaemonLocal(appWindow.currentDaemonAddress) && !appWindow.daemonSynced
            }

            // Text {
            //     id: soloMainLabel
            //     text: qsTr("Mining with your computer helps strengthen the BitTube network. The more that people mine, the harder it is for the network to be attacked, and every little bit helps.<br> <br>Mining also gives you a small chance to earn some TUBE. Your computer will create hashes looking for block solutions. If you find a block, you will get the associated reward. Good luck!") + translationManager.emptyString
            //     wrapMode: Text.Wrap
            //     Layout.fillWidth: true
            //     font.family: Style.fontRegular.name
            //     font.pixelSize: 14 * scaleRatio
            //     color: Style.defaultFontColor
            // }

            RowLayout {
                id: minerCpuCoresRow
                z: parent.z + 1
                Label {
                    id: minerCpuCoresLabel
                    color: Style.defaultFontColor
                    text: qsTr("CPU Cores") + translationManager.emptyString
                    fontSize: 16
                    Layout.preferredWidth: 120
                }

                ListModel {
                    id: minerCpuCores
                    // CPU Cores get added dynamically
                }

                StandardDropdown {
                    id: minerCpuCoresDropdown
                    anchors.topMargin: 2 * scaleRatio
                    fontHeaderSize: 14 * scaleRatio
                    dropdownHeight: 28 * scaleRatio
                    // Layout.fillWidth: false
                    Layout.preferredWidth: 120
                }
            }

            RowLayout {
                id: minerGpuActive
                CheckBox {
                    id: minerGpuActiveCheckbox
                    onClicked: {persistentSettings.minerGpuActiveCheckbox = checked}
                    text: qsTr("Use GPU for mining") + translationManager.emptyString
                }
            }

            ColumnLayout {
                id: minerGpus
                visible: minerGpuActiveCheckbox.checked
                // TODO: generate checkboxes dynmically for each GPU
            }

            RowLayout {
                id: miningPool
                Label {
                    id: miningPoolAddressLabel
                    color: Style.defaultFontColor
                    text: qsTr("Mining Pool") + translationManager.emptyString
                    fontSize: 16
                    Layout.preferredWidth: 120
                }

                LineEdit {
                    id: miningPoolAddressLine
                    // Layout.preferredWidth:  200
                    Layout.fillWidth: true
                    text: ""
                    placeholderText: qsTr("(optional)") + translationManager.emptyString
                    // validator: IntValidator { bottom: 1 }
                }

                LineEdit {
                    id: miningPoolPortLine
                    Layout.preferredWidth:  100
                    text: ""
                    placeholderText: qsTr("(optional)") + translationManager.emptyString
                    // validator: IntValidator { bottom: 4 }
                }
            }

            RowLayout {
                // Disable this option until stable
                visible: false
                Layout.leftMargin: 125
                CheckBox {
                    id: ignoreBattery
                    enabled: startSoloMinerButton.enabled
                    checked: !persistentSettings.miningIgnoreBattery
                    onClicked: {persistentSettings.miningIgnoreBattery = !checked}
                    text: qsTr("Enable mining when running on battery") + translationManager.emptyString
                }
            }

            RowLayout {
                Layout.leftMargin: 125
                StandardButton {
                    visible: true
                    //enabled: !walletManager.isMining()
                    id: startSoloMinerButton
                    width: 110
                    small: true
                    text: qsTr("Start mining") + translationManager.emptyString
                    onClicked: {
                        var success = walletManager.startMining(appWindow.currentWallet.address(0, 0), miningPoolAddressLine.text, miningPoolPortLine.text, minerCpuCoresDropdown.text, persistentSettings.allow_background_mining, persistentSettings.miningIgnoreBattery, persistentSettings.allow_gpu_mining)
                        if (success) {
                            // miningStatsTable.visible = true;
                            update()
                        } else {
                            errorPopup.title  = qsTr("Error starting mining") + translationManager.emptyString;
                            errorPopup.text = qsTr("Couldn't start mining.<br>")
                            if (!walletManager.isDaemonLocal(appWindow.currentDaemonAddress))
                                errorPopup.text += qsTr("Mining is only available on local daemons. Run a local daemon to be able to mine.<br>")
                            errorPopup.icon = StandardIcon.Critical
                            errorPopup.open()
                        }
                    }
                }

                StandardButton {
                    visible: true
                    id: stopSoloMinerButton
                    width: 110
                    small: true
                    text: qsTr("Stop mining") + translationManager.emptyString
                    onClicked: {
                        walletManager.stopMining()
                        update()
                    }
                }
            }

            // show stats "checkbox"
            RowLayout {
                // anchors.top: miningStatsTable.bottom
                CheckBox2 {
                    id: showStatsCheckbox
                    checked: persistentSettings.miningShowStats
                    onClicked: {
                        persistentSettings.miningShowStats = !persistentSettings.miningShowStats
                    }
                    text: qsTr("Show statistics") + translationManager.emptyString
                }
            }

            // divider
            Rectangle {
                id: showStatsDivider
                visible: persistentSettings.miningShowStats
                Layout.fillWidth: true
                height: 1
                color: Style.dividerColor
                opacity: Style.dividerOpacity
                // Layout.bottomMargin: 20
            }

            // stats table
            ColumnLayout {
                id: miningStatsTable
                // Layout.topMargin: 20
                Layout.fillWidth: true
                Layout.preferredHeight: 32 * miningStatsListView.count + 20 + miningStatsHashrateReportLabel.height
                visible: persistentSettings.miningShowStats
                // property int miningStatsListItemHeight: 32 * scaleRatio

                Rectangle {
                    Layout.preferredWidth: 120
                    height: miningStatsHashrateReportLabel.height
                    anchors.top: parent.top
                    Layout.bottomMargin: 20
                    id: miningStatsHashrateReportLabelContainer
                    color: "transparent"
                    
                    Label {
                        id: miningStatsHashrateReportLabel
                        color: Style.defaultFontColor
                        text: qsTr("Hashrate Report") + translationManager.emptyString
                        fontSize: 18
                        fontBold: true
                    }
                }

                Rectangle {
                    color: "transparent"
                    Layout.fillWidth: true
                    anchors.top: miningStatsHashrateReportLabelContainer.bottom
                    anchors.bottom: miningStatsTable.bottom

                    ListModel {
                        id: miningStatsTableModel
                        // fill with threads dynamically
                    }

                    ListView {
                        id: miningStatsListView
                        // Layout.topMargin: 20
                        anchors.fill: parent
                        model: miningStatsTableModel
                        header: headerComponent

                        Component {
                            id: headerComponent

                            // header rectangle
                            Rectangle {
                                id: miningsStatsTableHeaderRow
                                // anchors.fill: parent
                                color: "transparent"
                                height: 32
                                width: parent.width
                                // Layout.fillWidth: true

                                Label {
                                    id: threadIDHeaderLabel
                                    color: "#404040"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    width: parent.width / 4
                                    fontSize: 14 * scaleRatio
                                    fontBold: true
                                    text: "Thread ID"
                                }

                                Label {
                                    id: tenSecondHashRateHeaderLabel
                                    color: "#404040"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: threadIDHeaderLabel.right
                                    width: parent.width / 4
                                    // anchors.leftMargin: 100
                                    fontSize: 14 * scaleRatio
                                    fontBold: false
                                    text: "10s"
                                }

                                Label {
                                    id: sixtySecondHashRateHeaderLabel
                                    color: "#404040"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: tenSecondHashRateHeaderLabel.right
                                    width: parent.width / 4
                                    // anchors.leftMargin: 100
                                    fontSize: 14 * scaleRatio
                                    fontBold: false
                                    text: "60s"
                                }

                                Label {
                                    id: fifteenMinuteHashRateHeaderLabel
                                    color: "#404040"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: sixtySecondHashRateHeaderLabel.right
                                    width: parent.width / 4
                                    // anchors.leftMargin: 100
                                    fontSize: 14 * scaleRatio
                                    fontBold: false
                                    text: "15m"
                                }
                            }
                        }

                        delegate: Item {
                            id: tableItem2
                            height: 32
                            width: parent.width
                            Layout.fillWidth: true

                            // divider line
                            Rectangle {
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.top: parent.top
                                height: 1
                                color: Style.dividerColor
                                opacity: Style.dividerOpacity
                                visible: true
                            }

                            Label {
                                id: threadIDLabel
                                color: "#404040"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                width: parent.width / 4
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: index
                            }

                            Label {
                                id: tenSecondHashRateLabel
                                color: "#404040"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: threadIDLabel.right
                                width: parent.width / 4
                                // anchors.leftMargin: 100
                                fontSize: 14 * scaleRatio
                                fontBold: false
                                text: tenSecondHashRate
                            }

                            Label {
                                id: sixtySecondHashRateLabel
                                color: "#404040"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: tenSecondHashRateLabel.right
                                width: parent.width / 4
                                // anchors.leftMargin: 100
                                fontSize: 14 * scaleRatio
                                fontBold: false
                                text: sixtySecondHashRate
                            }

                            Label {
                                id: fifteenMinuteHashRateLabel
                                color: "#404040"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: sixtySecondHashRateLabel.right
                                width: parent.width / 4
                                // anchors.leftMargin: 100
                                fontSize: 14 * scaleRatio
                                fontBold: false
                                text: fifteenMinuteHashRate
                            }
                        }
                    }
                }
            }

            RowLayout {
                width: parent.width
                Layout.fillWidth: true
                visible: persistentSettings.miningShowStats
                Layout.topMargin: 32

                // results table
                ColumnLayout {
                    id: resultStatsTable
                    // anchors.top: showStatsDivider.bottom
                    Layout.topMargin: 32
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width / 2
                    Layout.preferredHeight: 128
                    anchors.top: parent.top
                    // visible: persistentSettings.miningShowStats

                    Rectangle {
                        id: miningStatsResultsReportLabelContainer
                        height: miningInfoTableReportLabel.height
                        anchors.top: parent.top
                        Layout.bottomMargin: 20
                        color: "transparent"

                        Label {
                            id: miningInfoTableReportLabel
                            color: Style.defaultFontColor
                            text: qsTr("Results Report") + translationManager.emptyString
                            fontSize: 18
                            // Layout.preferredWidth: 120
                            // Layout.bottomMargin: 20
                            fontBold: true
                        }
                    }

                    Rectangle {
                        color: "transparent"
                        Layout.fillWidth: true
                        width: parent.width
                        anchors.top: miningStatsResultsReportLabelContainer.bottom
                        anchors.bottom: resultStatsTable.bottom

                        ListModel {
                            id: miningResultReportTableModel
                            ListElement {
                                label: "Difficulty"
                                value: "0"
                            }
                            ListElement {
                                label: "Good results"
                                value: "0"
                            }
                            ListElement {
                                label: "Avg result time"
                                value: "0"
                            }
                            ListElement {
                                label: "Pool-side hashes"
                                value: "0"
                            }
                        }

                        ListView {
                            id: resultStatsListView
                            Layout.fillWidth: true
                            // Layout.topMargin: 20
                            anchors.fill: parent
                            // anchors.top: resultStatsHashrateReportLabel.bottom
                            // clip: true
                            // boundsBehavior: ListView.StopAtBounds
                            model: miningResultReportTableModel
                            
                            delegate: Item {
                                id: tableItem
                                height: 32
                                width: parent.width

                                // divider line
                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.left: parent.left
                                    anchors.top: parent.bottom
                                    height: 1
                                    color: Style.dividerColor
                                    opacity: Style.dividerOpacity
                                    visible: label != "Pool-side hashes"    //dont display last divider
                                }

                                Label {
                                    id: difficultyLabel
                                    color: "#404040"
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    fontSize: 14 * scaleRatio
                                    fontBold: true
                                    text: label
                                }

                                Label {
                                    id: difficultyValue
                                    color: "#404040"
                                    anchors.verticalCenter: parent.verticalCenter
                                    // anchors.left: difficultyLabel.right
                                    anchors.right: parent.right
                                    // anchors.leftMargin: 100
                                    fontSize: 14 * scaleRatio
                                    fontBold: false
                                    text: value
                                }
                            }
                        }
                    }
                }

                //top 10 results table
                ColumnLayout {
                    id: topResultStatsTable
                    Layout.topMargin: 32
                    Layout.leftMargin: 20
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width / 2
                    Layout.preferredHeight: 160
                    anchors.top: parent.top
                    
                    Rectangle {
                        id: topResultStatsLabelContainer
                        height: topResultStatsReportLabel.height
                        anchors.top: parent.top
                        Layout.bottomMargin: 20
                        color: "transparent"

                        Label {
                            id: topResultStatsReportLabel
                            color: Style.defaultFontColor
                            text: qsTr("Top 10 best results found") + translationManager.emptyString
                            fontSize: 18
                            fontBold: true
                        }
                    }

                    //table
                    RowLayout {
                        Layout.preferredHeight: 160
                        Layout.preferredWidth: parent.width
                        anchors.top: topResultStatsLabelContainer.bottom
                        Layout.topMargin: 32

                        //first half
                        ColumnLayout {
                            id: topResultStatsTable1
                            // Layout.leftMargin: 20
                            Layout.fillWidth: true
                            Layout.preferredWidth: parent.width / 2
                            Layout.preferredHeight: 160
                            anchors.top: parent.top

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                width: parent.width
                                anchors.top: parent.top
                                anchors.bottom: topResultStatsTable1.bottom

                                ListModel {
                                    id: topResultStatsModel1
                                    ListElement {
                                        label: "1"
                                        value: "0"
                                    }
                                    ListElement {
                                        label: "2"
                                        value: "0"
                                    }
                                    ListElement {
                                        label: "3"
                                        value: "0"
                                    }
                                    ListElement {
                                        label: "4"
                                        value: "0"
                                    }
                                    ListElement {
                                        label: "5"
                                        value: "0"
                                    }
                                }

                                ListView {
                                    id: topResultStatsListView1
                                    Layout.fillWidth: true
                                    anchors.fill: parent
                                    model: topResultStatsModel1
                                    
                                    delegate: Item {
                                        id: tableItem
                                        height: 32
                                        width: parent.width

                                        // divider line
                                        Rectangle {
                                            anchors.right: parent.right
                                            anchors.left: parent.left
                                            anchors.top: parent.bottom
                                            height: 1
                                            color: Style.dividerColor
                                            opacity: Style.dividerOpacity
                                            visible: true
                                        }

                                        Label {
                                            id: difficultyLabel
                                            color: "#404040"
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            fontSize: 14 * scaleRatio
                                            fontBold: true
                                            text: label
                                        }

                                        Label {
                                            id: difficultyValue
                                            color: "#404040"
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.right: parent.right
                                            fontSize: 14 * scaleRatio
                                            fontBold: false
                                            text: value
                                        }
                                    }
                                }
                            }
                        }

                        //second half
                        ColumnLayout {
                            id: topResultStatsTable2
                            // Layout.topMargin: 32
                            Layout.leftMargin: 20
                            Layout.fillWidth: true
                            Layout.preferredWidth: parent.width / 2
                            Layout.preferredHeight: 160
                            anchors.top: topResultStatsLabelContainer.bottom

                            Rectangle {
                                color: "transparent"
                                Layout.fillWidth: true
                                width: parent.width
                                anchors.top: parent.top
                                anchors.bottom: topResultStatsTable2.bottom

                                ListModel {
                                    id: topResultStatsModel2
                                    ListElement {
                                        label: "6"
                                        value: "0"
                                    }
                                    ListElement {
                                        label: "7"
                                        value: "0"
                                    }
                                    ListElement {
                                        label: "8"
                                        value: "0"
                                    }
                                    ListElement {
                                        label: "9"
                                        value: "0"
                                    }
                                    ListElement {
                                        label: "10"
                                        value: "0"
                                    }
                                }

                                ListView {
                                    id: topResultStatsListView2
                                    Layout.fillWidth: true
                                    anchors.fill: parent
                                    model: topResultStatsModel2
                                    
                                    delegate: Item {
                                        id: tableItem
                                        height: 32
                                        width: parent.width

                                        // divider line
                                        Rectangle {
                                            anchors.right: parent.right
                                            anchors.left: parent.left
                                            anchors.top: parent.bottom
                                            height: 1
                                            color: Style.dividerColor
                                            opacity: Style.dividerOpacity
                                            visible: true
                                        }

                                        Label {
                                            id: difficultyLabel
                                            color: "#404040"
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            fontSize: 14 * scaleRatio
                                            fontBold: true
                                            text: label
                                        }

                                        Label {
                                            id: difficultyValue
                                            color: "#404040"
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.right: parent.right
                                            fontSize: 14 * scaleRatio
                                            fontBold: false
                                            text: value
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // connection report table
            ColumnLayout {
                id: connectionReportTable
                Layout.fillWidth: true
                visible: persistentSettings.miningShowStats
                Layout.preferredHeight: 96
                    
                Rectangle {
                    id: connectionReportTableLabelContainer
                    height: connectionReportTableLabel.height
                    anchors.top: parent.top
                    Layout.bottomMargin: 20
                    color: "transparent"

                    Label {
                        id: connectionReportTableLabel
                        color: Style.defaultFontColor
                        text: qsTr("Connection Report") + translationManager.emptyString
                        fontSize: 18
                        fontBold: true
                    }
                }
                
                Rectangle {
                    color: "transparent"
                    Layout.fillWidth: true
                    width: parent.width
                    anchors.top: connectionReportTableLabelContainer.bottom
                    anchors.bottom: connectionReportTable.bottom

                    ListModel {
                        id: connectionReportTableModel
                        ListElement {
                            label: "Pool address"
                            value: "0"
                        }
                        ListElement {
                            label: "Connected since"
                            value: "0"
                        }
                        ListElement {
                            label: "Pool ping time"
                            value: "0"
                        }
                    }

                    ListView {
                        id: connectionReportListView
                        Layout.fillWidth: true
                        anchors.fill: parent
                        model: connectionReportTableModel
                        
                        delegate: Item {
                            id: tableItem
                            height: 32
                            width: parent.width

                            // divider line
                            Rectangle {
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.top: parent.bottom
                                height: 1
                                color: Style.dividerColor
                                opacity: Style.dividerOpacity
                                visible: label != "Pool-side hashes"    //dont display last divider
                            }

                            Label {
                                id: connectionLabel
                                color: "#404040"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: label
                            }

                            Label {
                                id: connectionValue
                                color: "#404040"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                fontSize: 14 * scaleRatio
                                fontBold: false
                                text: value
                            }
                        }
                    }
                }
            }

            
            // Text {
            //     id: statusText
            //     text: qsTr("Status: not mining")
            //     color: Style.defaultFontColor
            //     textFormat: Text.RichText
            //     wrapMode: Text.Wrap
            // }
        }
    }

    function updateStatusText() {
        var text = ""
        if (walletManager.isMining()) {
            if (text !== "")
                text += "<br>";
            text += qsTr("Mining at %1 H/s").arg(walletManager.miningHashRate())
        }
        if (text === "") {
            text += qsTr("Not mining") + translationManager.emptyString;
        }
        statusText.text = qsTr("Status: ") + text
    }

    function update() {
        // updateStatusText()
        var infoReqSuccess = walletManager.requestInfo();
        var statsReqSuccess = walletManager.requestStats();

        if(infoReqSuccess == true || statsReqSuccess == true) {
            return;
        }

        startSoloMinerButton.enabled = !walletManager.isMining()
        stopSoloMinerButton.enabled = !startSoloMinerButton.enabled
        // miningStatsTable.visible = walletManager.isMining()

        // get & parse json from miner
        var stats_json_str = walletManager.stats_json();
        var info_json_str = walletManager.info_json();

        if (stats_json_str == "" || info_json_str == "") {
            return;
        }

        var stats_json = JSON.parse(stats_json_str);
        var info_json = JSON.parse(info_json_str);
        
        // update result report table
        miningResultReportTableModel.set(0, {"value" : String(stats_json.results.diff_current)});
        miningResultReportTableModel.set(1, {"value" : String(stats_json.results.shares_good)});
        miningResultReportTableModel.set(2, {"value" : String(stats_json.results.avg_time)});
        miningResultReportTableModel.set(3, {"value" : String(stats_json.results.hashes_total)});

        resultStatsListView.model = 0;
        resultStatsListView.model = miningResultReportTableModel;
        
        // update hashrate report table
        miningStatsTableModel.clear();
        for(var n = 0; n < stats_json.hashrate.threads.length; n ++){
            miningStatsTableModel.append({  "index": String(n), 
                                            "tenSecondHashRate": String(stats_json.hashrate.threads[n][0]), 
                                            "sixtySecondHashRate": String(stats_json.hashrate.threads[n][1]), 
                                            "fifteenMinuteHashRate": String(stats_json.hashrate.threads[n][2])
                                        });
        }
        //append totals
        miningStatsTableModel.append({  "index": "Total",
                                        "tenSecondHashRate": String(stats_json.hashrate.total[0]),
                                        "sixtySecondHashRate": String(stats_json.hashrate.total[1]),
                                        "fifteenMinuteHashRate": String(stats_json.hashrate.total[2])
                                    });
        //append Highgest
        miningStatsTableModel.append({  "index": "Highest",
                                        "tenSecondHashRate": String(stats_json.hashrate.highest),
                                        "sixtySecondHashRate": "",
                                        "fifteenMinuteHashRate": ""
                                    });
        miningStatsListView.model = 0;
        miningStatsListView.model = miningStatsTableModel;

        //update top 10 results table
        topResultStatsModel1.set(0, {"value": String(stats_json.results.best[0])});
        topResultStatsModel1.set(1, {"value": String(stats_json.results.best[1])});
        topResultStatsModel1.set(2, {"value": String(stats_json.results.best[2])});
        topResultStatsModel1.set(3, {"value": String(stats_json.results.best[3])});
        topResultStatsModel1.set(4, {"value": String(stats_json.results.best[4])});
        topResultStatsModel2.set(0, {"value": String(stats_json.results.best[5])});
        topResultStatsModel2.set(1, {"value": String(stats_json.results.best[6])});
        topResultStatsModel2.set(2, {"value": String(stats_json.results.best[7])});
        topResultStatsModel2.set(3, {"value": String(stats_json.results.best[8])});
        topResultStatsModel2.set(4, {"value": String(stats_json.results.best[9])});

        //update connection report table
        connectionReportTableModel.set(0, {"value": String(stats_json.connection.pool)});
        connectionReportTableModel.set(1, {"value": String(stats_json.connection.uptime) + " seconds"});
        connectionReportTableModel.set(2, {"value": String(stats_json.connection.ping)});
    }

    StandardDialog {
        id: errorPopup
        cancelVisible: false
    }

    Timer {
        id: timer
        interval: 2000; running: false; repeat: true
        onTriggered: update()
    }

    function onPageCompleted() {
        console.log("Mining page loaded");

        update()
        timer.running = walletManager.isDaemonLocal(appWindow.currentDaemonAddress)

        //update CPU Cores
        if (walletManager.cpuCoreCount() != 0) {
            for(var n=1; n<=walletManager.cpuCoreCount(); n++) {
                minerCpuCores.append( {column1: qsTr(String(n))});
            }
        }
        else {
            minerCpuCores.append( {column1: qsTr("0")});
        }
        minerCpuCoresDropdown.dataModel = minerCpuCores;
        minerCpuCoresDropdown.currentIndex = 0;
        minerCpuCoresDropdown.update();

        //update pool Address & Port
        var poolAddress = walletManager.poolAddress().split(":");
        miningPoolAddressLine.text = poolAddress[0];
        miningPoolPortLine.text = poolAddress[1]

        //update nvidia GPU list
        var nvidia_list = walletManager.nvidiaList();

        for(var i = 0; i < nvidia_list.length; i++) {
            // var checkboxComponent = Qt.createComponent('CheckBox.qml');
            
            // if (checkboxComponent.status === checkboxComponent.Ready || checkboxComponent.status === checkboxComponent.Error) {
            //     var gpuCheckBox = checkboxComponent.createObject(minerGpus);
            //     if (gpuCheckBox != null) {
            //         gpuCheckBox.text = qsTr(nvidia_list[i]) + translationManager.emptyString;
            //     }
            // }

            var newCheckBox = Qt.createQmlObject("import QtQuick 2.0; import '../components'; CheckBox {text: qsTr('" + nvidia_list[i] + "') + translationManager.emptyString;}", minerGpus, "dynamicItem");
        }

    }
    function onPageClosed() {
        timer.running = false
    }
}