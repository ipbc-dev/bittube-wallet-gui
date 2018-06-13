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
        anchors.bottom: parent.bottom
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
                    // TODO: fill in the available CPU Cores
                    // HARDCODED FOR NOW
                    ListElement {column1: qsTr("1"); column2: "";}
                    ListElement {column1: qsTr("2"); column2: "";}
                    ListElement {column1: qsTr("3"); column2: "";}
                    ListElement {column1: qsTr("4"); column2: "";}
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

            RowLayout {
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
                    text: "mining.bit.tube"
                    placeholderText: qsTr("(optional)") + translationManager.emptyString
                    // validator: IntValidator { bottom: 1 }
                }

                LineEdit {
                    id: miningPoolPortLine
                    Layout.preferredWidth:  100
                    text: "13333"
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
                        var success = walletManager.startMining(appWindow.currentWallet.address(0, 0), miningPoolAddressLine.text, miningPoolPortLine.text, soloMinerThreadsLine.text, persistentSettings.allow_background_mining, persistentSettings.miningIgnoreBattery, persistentSettings.allow_gpu_mining)
                        if (success) {
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

            // stats table
            ColumnLayout {
                id: miningStatsTable
                property int miningStatsListItemHeight: 32 * scaleRatio
                visible: false
                Layout.fillWidth: true

                Label {
                    id: miningStatsHashrateReportLabel
                    color: Style.defaultFontColor
                    text: qsTr("Hashrate Report") + translationManager.emptyString
                    fontSize: 18
                    Layout.preferredWidth: 120
                    Layout.bottomMargin: 20
                }

                ListView {
                    id: miningStatsListView
                    Layout.fillWidth: true
                    anchors.fill: parent
                    clip: true
                    boundsBehavior: ListView.StopAtBounds

                    // header rectangle
                    Rectangle {
                        anchors.fill: parent
                        anchors.rightMargin: 80
                        color: "transparent"

                        Label {
                            id: threadIDHeaderLabel
                            color: "#404040"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            fontSize: 14 * scaleRatio
                            fontBold: true
                            text: "Thread ID"
                        }

                        Label {
                            id: tenSecondHashRateHeaderLabel
                            color: "#404040"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: threadIDHeaderLabel.right
                            anchors.leftMargin: 100
                            fontSize: 14 * scaleRatio
                            fontBold: false
                            text: "10s"
                        }

                        Label {
                            id: sixtySecondHashRateHeaderLabel
                            color: "#404040"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: tenSecondHashRateHeaderLabel.right
                            anchors.leftMargin: 100
                            fontSize: 14 * scaleRatio
                            fontBold: false
                            text: "60s"
                        }

                        Label {
                            id: fifteenMinuteHashRateHeaderLabel
                            color: "#404040"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: sixtySecondHashRateHeaderLabel.right
                            anchors.leftMargin: 100
                            fontSize: 14 * scaleRatio
                            fontBold: false
                            text: "15m"
                        }
                    }

                    delegate: Rectangle {
                        id: tableItem2
                        height: miningStatsTable.miningStatsListItemHeight
                        width: parent.width
                        Layout.fillWidth: true
                        color: "transparent"
                        
                        // divider line
                        Rectangle {
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.top: parent.top
                            height: 1
                            color: "#404040"
                            visible: index !== 0
                        }

                        // item rectangle
                        Rectangle {
                            anchors.fill: parent
                            anchors.rightMargin: 80
                            color: "transparent"

                            Label {
                                id: threadIDLabel
                                color: "#404040"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: index
                            }

                            Label {
                                id: tenSecondHashRateLabel
                                color: "#404040"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: threadIDLabel.right
                                anchors.leftMargin: 100
                                fontSize: 14 * scaleRatio
                                fontBold: false
                                text: tenSecondHashRate
                            }

                            Label {
                                id: sixtySecondHashRateLabel
                                color: "#404040"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: tenSecondHashRateLabel.right
                                anchors.leftMargin: 100
                                fontSize: 14 * scaleRatio
                                fontBold: false
                                text: sixtySecondHashRate
                            }

                            Label {
                                id: fifteenMinuteHashRateLabel
                                color: "#404040"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: sixtySecondHashRateLabel.right
                                anchors.leftMargin: 100
                                fontSize: 14 * scaleRatio
                                fontBold: false
                                text: fifteenMinuteHashRate
                            }
                        }
                     }
                }
            }

            // show stats "checkbox"
            RowLayout {
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

            // Rectangle {
            //     visible: persistentSettings.miningShowStats
            //     Layout.topMargin: 20
            //     Layout.preferredWidth: 120
            //     anchors.top: showStatsDivider.bottom

            //     Label {
            //         anchors.fill: parent
            //         id: resultStatsHashrateReportLabel
            //         color: Style.defaultFontColor
            //         text: qsTr("Result Report") + translationManager.emptyString
            //         fontSize: 18
            //     }
            // }

            // results table
            ColumnLayout {
                id: resultStatsTable
                anchors.top: showStatsDivider.bottom
                Layout.topMargin: 20
                Layout.fillWidth: true
                Layout.preferredHeight: 46 * resultStatsListView.count
                visible: persistentSettings.miningShowStats

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
                    Layout.topMargin: 20
                    anchors.fill: parent
                    // anchors.top: resultStatsHashrateReportLabel.bottom
                    // clip: true
                    // boundsBehavior: ListView.StopAtBounds
                    model: miningResultReportTableModel
                    
                    delegate: Item {
                        id: tableItem
                        height: 46
                        width: parent.width
                        Layout.fillWidth: true

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
                    }
                }
            }
        }

        Text {
            id: statusText
            text: qsTr("Status: not mining")
            color: Style.defaultFontColor
            textFormat: Text.RichText
            wrapMode: Text.Wrap
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
        updateStatusText()
        startSoloMinerButton.enabled = !walletManager.isMining()
        stopSoloMinerButton.enabled = !startSoloMinerButton.enabled
        miningStatsTable.visible = walletManager.isMining()
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
        minerCpuCoresDropdown.dataModel = minerCpuCores;
        minerCpuCoresDropdown.currentIndex = 0;
        minerCpuCoresDropdown.update();
    }
    function onPageClosed() {
        timer.running = false
    }
}
