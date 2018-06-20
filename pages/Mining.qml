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
    property alias miningHeight: mainLayout.height

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
                Layout.fillWidth: true
                z: parent.z + 1
                anchors.left: parent.left
                anchors.right: parent.right

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

                //h/s label
                Rectangle {
                    width: 100
                    height: 28
                    anchors.right: parent.right
                    anchors.top: minerCpuCoresLabel.top
                    color: "transparent"

                    Label {
                        id: totalHashSec10SecLabel
                        color: Style.defaultFontColor
                        text: ""
                        fontSize: 18
                    }
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
                        interactive: false

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
                                    text: qsTr("Thread ID") + translationManager.emptyString
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
                                    text: qsTr("10s") + translationManager.emptyString
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
                                    text: qsTr("60s") + translationManager.emptyString
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
                                    text: qsTr("15m") + translationManager.emptyString
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
                            anchors.fill: parent
                            model: miningResultReportTableModel
                            interactive: false
                            
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
                                    interactive: false
                                    
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
                                    interactive: false
                                    
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
                        interactive: false
                        
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

    function reset_all(){
        miningResultReportTableModel.set(0, {"value" : ""});
        miningResultReportTableModel.set(1, {"value" : ""});
        miningResultReportTableModel.set(2, {"value" : ""});
        miningResultReportTableModel.set(3, {"value" : ""});
        resultStatsListView.model = 0;
        resultStatsListView.model = miningResultReportTableModel;

        miningStatsTableModel.clear();

        for(var n = 0; n <= 4; n ++){
            topResultStatsModel1.set(n, {"value": ""});
        }

        for(var n = 0; n <= 4; n ++){
            topResultStatsModel2.set(n, {"value": ""});
        }

        connectionReportTableModel.set(0, {"value": ""});
        connectionReportTableModel.set(1, {"value": ""});
        connectionReportTableModel.set(2, {"value": ""});

        totalHashSec10SecLabel.text = "";
    }

    function update() {
        var info_json = readInfoJson();
        if (info_json == null) {
            reset_all();
            return;
        }

        //handle start & stop buttons
        startSoloMinerButton.enabled = !walletManager.isMining()
        stopSoloMinerButton.enabled = !startSoloMinerButton.enabled

        var stats_json = readStatsJson();
        if (stats_json == null) {
            reset_all();
            return;
        }
        
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
            var tenSecondHashRate = String(stats_json.hashrate.threads[n][0]);
            var sixtySecondHashRate = String(stats_json.hashrate.threads[n][1]);
            var fifteenMinuteHashRate = String(stats_json.hashrate.threads[n][2]);

            if (tenSecondHashRate == "null"){ tenSecondHashRate = ""};
            if (sixtySecondHashRate == "null"){ sixtySecondHashRate = ""};
            if (fifteenMinuteHashRate == "null"){ fifteenMinuteHashRate = ""};

            miningStatsTableModel.append({  "index": String(n), "tenSecondHashRate": tenSecondHashRate, "sixtySecondHashRate": sixtySecondHashRate, "fifteenMinuteHashRate": fifteenMinuteHashRate});
        }

        //append totals
        var totalTenSecondHashRate = String(stats_json.hashrate.total[0]);
        var totalSixtySecondHashRate = String(stats_json.hashrate.total[1]);
        var totalFifteenMinuteHashRate = String(stats_json.hashrate.total[2]);

        if (totalTenSecondHashRate == "null"){ totalTenSecondHashRate = ""};
        if (totalSixtySecondHashRate == "null"){ totalSixtySecondHashRate = ""};
        if (totalFifteenMinuteHashRate == "null"){ totalFifteenMinuteHashRate = ""};

        miningStatsTableModel.append({  "index": "Total", "tenSecondHashRate": totalTenSecondHashRate, "sixtySecondHashRate": totalSixtySecondHashRate, "fifteenMinuteHashRate": totalFifteenMinuteHashRate});

        //append Highgest
        var highestTenSecondHashRate = String(stats_json.hashrate.highest);

        if (highestTenSecondHashRate == "null"){ highestTenSecondHashRate = ""};

        miningStatsTableModel.append({  "index": "Highest", "tenSecondHashRate": highestTenSecondHashRate, "sixtySecondHashRate": "", "fifteenMinuteHashRate": ""});
        miningStatsListView.model = 0;
        miningStatsListView.model = miningStatsTableModel;

        //update top 10 results table
        for(var n = 0; n <= 4; n ++){
            topResultStatsModel1.set(n, {"value": String(stats_json.results.best[n])});
        }

        for(var n = 0; n <= 4; n ++){
            topResultStatsModel2.set(n, {"value": String(stats_json.results.best[n + 5])});
        }

        //update connection report table
        connectionReportTableModel.set(0, {"value": String(stats_json.connection.pool)});
        connectionReportTableModel.set(1, {"value": String(stats_json.connection.uptime) + " seconds"});
        connectionReportTableModel.set(2, {"value": String(stats_json.connection.ping)});

        //populate h/s label
        if(stats_json.hashrate.total[0] != null){
            totalHashSec10SecLabel.text = String(stats_json.hashrate.total[0]) + " h/s";
        }
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

    function readInfoJson() {
        var infoReqSuccess = walletManager.requestInfo();
        if(infoReqSuccess == true) {
            return null;
        }

        var info_json_str = walletManager.info_json();
        if (info_json_str == "") {
            return null;
        }

        var info_json = JSON.parse(info_json_str);
        if(info_json.length == 0){
            return null;
        }

        if (!info_json.hasOwnProperty("cpu_count")){
            return null;
        }

        return info_json;
    }

    function readStatsJson() {
        var statsReqSuccess = walletManager.requestStats();
        if(statsReqSuccess == true) {
            return null;
        }

        var stats_json_str = walletManager.stats_json();
        if (stats_json_str == "") {
            return null;
        }

        var stats_json = JSON.parse(stats_json_str);
        if(stats_json.length == 0){
            return null;
        }

        if (!stats_json.hasOwnProperty("results")){
            return null;
        }

        return stats_json;
    }


    function onPageCompleted() {
        console.log("Mining page loaded");

        //get json
        var info_json = readInfoJson();
        if (info_json == null) {
            reset_all();
            return;
        }

        update()
        timer.running = walletManager.isDaemonLocal(appWindow.currentDaemonAddress)

        //update table labels for translations to work
        connectionReportTableModel.set(0, {"label": qsTr("Pool address") + translationManager.emptyString});
        connectionReportTableModel.set(1, {"label": qsTr("Connected since") + translationManager.emptyString});
        connectionReportTableModel.set(2, {"label": qsTr("Pool ping time") + translationManager.emptyString});

        miningResultReportTableModel.set(0, {"label" : qsTr("Difficulty") + translationManager.emptyString});
        miningResultReportTableModel.set(1, {"label" : qsTr("Good results") + translationManager.emptyString});
        miningResultReportTableModel.set(2, {"label" : qsTr("Avg result time") + translationManager.emptyString});
        miningResultReportTableModel.set(3, {"label" : qsTr("Pool-side hashes") + translationManager.emptyString});

        //update CPU Cores
        minerCpuCores.clear();
        if (info_json.cpu_count != 0) {
            for (var n = 1; n <= info_json.cpu_count; n ++) {
                minerCpuCores.append({column1: qsTr(String(n))});
            }
        } else {
            minerCpuCores.append({column1: qsTr("0")});
        }
        minerCpuCoresDropdown.dataModel = minerCpuCores;
        minerCpuCoresDropdown.currentIndex = 0;
        minerCpuCoresDropdown.update();

        //update pool Address & Port
        var poolAddress = info_json.pool_address;
        poolAddress = poolAddress.split(":");
        miningPoolAddressLine.text = poolAddress[0];
        miningPoolPortLine.text = poolAddress[1];

        //update nvidia GPU list
        var nvidia_list = info_json.nvidia_list;

        //remove old
        for(var i = minerGpus.children.length; i > 0 ; i--) {
            console.log("destroying: " + i)
            minerGpus.children[i-1].destroy()
        }

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