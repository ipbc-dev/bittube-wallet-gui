// Copyright (c) 2014-2018, The Monero Project
// Copyright (c) 2018, The BitTube Project
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

import QtQuick 2.9
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import FontAwesome 1.0

import "../components" as BittubeComponents
import "../components/effects/" as MoneroEffects

import bittubeComponents.Clipboard 1.0
import bittubeComponents.Wallet 1.0
import bittubeComponents.WalletManager 1.0
import bittubeComponents.TransactionHistory 1.0
import bittubeComponents.TransactionHistoryModel 1.0
import bittubeComponents.Subaddress 1.0
import bittubeComponents.SubaddressModel 1.0
import "../js/TxUtils.js" as TxUtils

Rectangle {
    id: pageReceive
    color: "transparent"
    property var model
    property var current_address
    property alias receiveHeight: mainLayout.height
    property alias addressText : pageReceive.current_address

    function makeQRCodeString() {
        var s = "bittube:"
        var nfields = 0
        s += current_address;
        var amount = amountToReceiveLine.text.trim()
        if (amount !== "" && amount.slice(-1) !== ".") {
          s += (nfields++ ? "&" : "?")
          s += "tx_amount=" + amount
        }
        return s
    }

    function update() {
        //hide subaddress creation until blockchainheight 110k
        if (walletManager.blockchainHeight() > 110000){
            createAddressRow.visible = true;
        } else {
            createAddressRow.visible = false;
        }

        if (!appWindow.currentWallet || !trackingEnabled.checked) {
            trackingLineText.text = "";
            trackingModel.clear();
            return
        }
        if (appWindow.currentWallet.connected() == Wallet.ConnectionStatus_Disconnected) {
            trackingLineText.text = qsTr("WARNING: no connection to daemon");
            trackingModel.clear();
            return
        }

        var model = appWindow.currentWallet.historyModel
        var count = model.rowCount()
        var totalAmount = 0
        var nTransactions = 0
        var blockchainHeight = 0
        var txs = []

        for (var i = 0; i < count; ++i) {
            var idx = model.index(i, 0)
            var isout = model.data(idx, TransactionHistoryModel.TransactionIsOutRole);
            var subaddrAccount = model.data(idx, TransactionHistoryModel.TransactionSubaddrAccountRole);
            var subaddrIndex = model.data(idx, TransactionHistoryModel.TransactionSubaddrIndexRole);
            if (!isout && subaddrAccount == appWindow.currentWallet.currentSubaddressAccount && subaddrIndex == current_subaddress_table_index) {
                var amount = model.data(idx, TransactionHistoryModel.TransactionAtomicAmountRole);
                totalAmount = walletManager.addi(totalAmount, amount)
                nTransactions += 1

                var txid = model.data(idx, TransactionHistoryModel.TransactionHashRole);
                var blockHeight = model.data(idx, TransactionHistoryModel.TransactionBlockHeightRole);

                var in_txpool = false;
                var confirmations = 0;
                var displayAmount = 0;

                if (blockHeight == 0) {
                    in_txpool = true;
                } else {
                    if (blockchainHeight == 0)
                        blockchainHeight = walletManager.blockchainHeight()
                    confirmations = blockchainHeight - blockHeight - 1
                    displayAmount = model.data(idx, TransactionHistoryModel.TransactionDisplayAmountRole);
                }

                txs.push({
                    "amount": displayAmount,
                    "confirmations": confirmations,
                    "blockheight": blockHeight,
                    "in_txpool": in_txpool,
                    "txid": txid
                })
            }
        }

        // Update tracking status label
        if (nTransactions == 0) {
            trackingLineText.text = qsTr("No transaction found yet...") + translationManager.emptyString
            return
        }
        else if(nTransactions === 1){
            trackingLineText.text = qsTr("Transaction found") + ":" + translationManager.emptyString;
        } else {
            trackingLineText.text = qsTr("%1 transactions found").arg(nTransactions) + ":" + translationManager.emptyString
        }

        var max_tracking = 3;
        toReceiveSatisfiedLine.text = "";
        var expectedAmount = walletManager.amountFromString(amountToReceiveLine.text)
        if (expectedAmount && expectedAmount != amount) {
            var displayTotalAmount = walletManager.displayAmount(totalAmount)
            if (amount > expectedAmount) toReceiveSatisfiedLine.text += qsTr("With more TUBE");
            else if (amount < expectedAmount) toReceiveSatisfiedLine.text = qsTr("With not enough TUBE")
            toReceiveSatisfiedLine.text += ": " + "<br>" +
                    qsTr("Expected") + ": " + amountToReceiveLine.text + "<br>" +
                    qsTr("Total received") + ": " + displayTotalAmount + translationManager.emptyString;
        }

        trackingModel.clear();

        if (txs.length > 3) {
            txs.length = 3;
        }

        txs.forEach(function(tx){
            trackingModel.append({
                "amount": tx.amount,
                "confirmations": tx.confirmations,
                "blockheight": tx.blockHeight,
                "in_txpool": tx.in_txpool,
                "txid": tx.txid
            });
        });

        //setTrackingLineText(text + "<br>" + list.join("<br>"))
    }

    function renameSubaddressLabel(_index){
        inputDialog.labelText = qsTr("Set the label of the selected address:") + translationManager.emptyString;
        inputDialog.onAcceptedCallback = function() {
            appWindow.currentWallet.subaddress.setLabel(appWindow.currentWallet.currentSubaddressAccount, _index, inputDialog.inputText);
        }
        inputDialog.onRejectedCallback = null;
        inputDialog.open(appWindow.currentWallet.getSubaddressLabel(appWindow.currentWallet.currentSubaddressAccount, _index))
    }

    Clipboard { id: clipboard }

    /* main layout */
    ColumnLayout {
        id: mainLayout
        anchors.margins: 20
        anchors.topMargin: 40

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 20

        ColumnLayout {
            id: addressRow
            spacing: 0

            BittubeComponents.LabelSubheader {
                Layout.fillWidth: true
                fontSize: 24
                textFormat: Text.RichText
                text: qsTr("Addresses") + translationManager.emptyString
            }

            ColumnLayout {
                id: subaddressListRow
                property int subaddressListItemHeight: 50
                Layout.topMargin: 6
                Layout.fillWidth: true
                Layout.minimumWidth: 240
                Layout.preferredHeight: subaddressListItemHeight * subaddressListView.count
                visible: subaddressListView.count >= 1

                ListView {
                    id: subaddressListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    boundsBehavior: ListView.StopAtBounds
                    interactive: false

                    delegate: Rectangle {
                        id: tableItem2
                        height: subaddressListRow.subaddressListItemHeight
                        width: parent.width
                        Layout.fillWidth: true
                        color: "transparent"

                        Rectangle{
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.top: parent.top
                            height: 1
                            color: BittubeComponents.Style.appWindowBorderColor
                            visible: index !== 0

                            MoneroEffects.ColorTransition {
                                targetObj: parent
                                blackColor: BittubeComponents.Style._b_appWindowBorderColor
                                whiteColor: BittubeComponents.Style._w_appWindowBorderColor
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            anchors.topMargin: 5
                            anchors.rightMargin: 80
                            color: "transparent"

                            BittubeComponents.Label {
                                id: idLabel
                                color: index === appWindow.current_subaddress_table_index ? BittubeComponents.Style.defaultFontColor : "#757575"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 6
                                fontSize: 16
                                text: "#" + index
                                themeTransition: false
                            }

                            BittubeComponents.Label {
                                id: nameLabel
                                color: BittubeComponents.Style.dimmedFontColor
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: idLabel.right
                                anchors.leftMargin: 6
                                fontSize: 16
                                text: label
                                elide: Text.ElideRight
                                textWidth: addressLabel.x - nameLabel.x - 1
                                themeTransition: false
                            }

                            BittubeComponents.Label {
                                id: addressLabel
                                color: BittubeComponents.Style.defaultFontColor
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.right
                                anchors.leftMargin: -addressLabel.width - 5
                                fontSize: 16
                                fontFamily: BittubeComponents.Style.fontMonoRegular.name;
                                text: TxUtils.addressTruncatePretty(address, mainLayout.width < 520 ? 1 : (mainLayout.width < 650 ? 2 : 3))
                                themeTransition: false
                            }

                            MouseArea {
                                cursorShape: Qt.PointingHandCursor
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: tableItem2.color = BittubeComponents.Style.titleBarButtonHoverColor
                                onExited: tableItem2.color = "transparent"
                                onClicked: subaddressListView.currentIndex = index;
                            }
                        }

                        RowLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 6
                            height: 21
                            spacing: 10

                            BittubeComponents.IconButton {
                                id: renameButton
                                image: "qrc:///images/edit.svg"
                                color: BittubeComponents.Style.defaultFontColor
                                opacity: 0.5
                                Layout.preferredWidth: 23
                                Layout.preferredHeight: 21
                                visible: index !== 0

                                onClicked: {
                                    renameSubaddressLabel(index);
                                }
                            }

                            BittubeComponents.IconButton {
                                id: copyButton
                                image: "qrc:///images/copy.svg"
                                color: BittubeComponents.Style.defaultFontColor
                                opacity: 0.5
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 21

                                onClicked: {
                                    console.log("Address copied to clipboard");
                                    clipboard.setText(address);
                                    appWindow.showStatusMessage(qsTr("Address copied to clipboard"),3);
                                }
                            }
                        }
                    }
                    onCurrentItemChanged: {
                        // reset global vars
                        appWindow.current_subaddress_table_index = subaddressListView.currentIndex;
                        appWindow.current_address = appWindow.currentWallet.address(
                            appWindow.currentWallet.currentSubaddressAccount,
                            subaddressListView.currentIndex
                        );
                    }
                }
            }

            Rectangle {
                color: BittubeComponents.Style.appWindowBorderColor
                Layout.fillWidth: true
                height: 1

                MoneroEffects.ColorTransition {
                    targetObj: parent
                    blackColor: BittubeComponents.Style._b_appWindowBorderColor
                    whiteColor: BittubeComponents.Style._w_appWindowBorderColor
                }
            }

            BittubeComponents.CheckBox {
                id: addNewAddressCheckbox
                border: false
                uncheckedIcon: FontAwesome.plusCircle
                toggleOnClick: false
                fontAwesomeIcons: true
                fontSize: 16
                iconOnTheLeft: true
                Layout.fillWidth: true
                Layout.topMargin: 10
                text: qsTr("Create new address") + translationManager.emptyString;
                onClicked: {
                    inputDialog.labelText = qsTr("Set the label of the new address:") + translationManager.emptyString
                    inputDialog.onAcceptedCallback = function() {
                        appWindow.currentWallet.subaddress.addRow(appWindow.currentWallet.currentSubaddressAccount, inputDialog.inputText)
                        current_subaddress_table_index = appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount) - 1
                        subaddressListView.currentIndex = current_subaddress_table_index
                    }
                    inputDialog.onRejectedCallback = null;
                    inputDialog.open()
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 11
            property int qrSize: 220

            Rectangle {
                id: qrContainer
                color: BittubeComponents.Style.blackTheme ? "white" : "transparent"
                Layout.fillWidth: true
                Layout.maximumWidth: parent.qrSize
                Layout.preferredHeight: width
                radius: 4

                Image {
                    id: qrCode
                    anchors.fill: parent
                    anchors.margins: 1

                    smooth: false
                    fillMode: Image.PreserveAspectFit
                    source: "image://qrcode/" + TxUtils.makeQRCodeString(appWindow.current_address)

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onPressAndHold: qrFileDialog.open()
                    }
                }
            }

            BittubeComponents.StandardButton {
                Layout.preferredWidth: 220
                small: true
                text: FontAwesome.save + "  %1".arg(qsTr("Save as image")) + translationManager.emptyString
                label.font.family: FontAwesome.fontFamily
                fontSize: 13
                onClicked: qrFileDialog.open()
            }

            BittubeComponents.StandardButton {
                Layout.preferredWidth: 220
                small: true
                text: FontAwesome.clipboard + "  %1".arg(qsTr("Copy to clipboard")) + translationManager.emptyString
                label.font.family: FontAwesome.fontFamily
                fontSize: 13
                onClicked: {
                    clipboard.setText(TxUtils.makeQRCodeString(appWindow.current_address));
                    appWindow.showStatusMessage(qsTr("Copied to clipboard") + translationManager.emptyString, 3);
                }
            }

            BittubeComponents.StandardButton {
                Layout.preferredWidth: 220
                small: true
                text: FontAwesome.eye + "  %1".arg(qsTr("Show on device")) + translationManager.emptyString
                label.font.family: FontAwesome.fontFamily
                fontSize: 13
                visible: appWindow.currentWallet ? appWindow.currentWallet.isHwBacked() : false
                onClicked: {
                    appWindow.currentWallet.deviceShowAddressAsync(
                        appWindow.currentWallet.currentSubaddressAccount,
                        appWindow.current_subaddress_table_index,
                        '');
                }
            }
        }

        MessageDialog {
            id: receivePageDialog
            standardButtons: StandardButton.Ok
        }

        FileDialog {
            id: qrFileDialog
            title: qsTr("Please choose a name") + translationManager.emptyString
            folder: shortcuts.pictures
            selectExisting: false
            nameFilters: ["Image (*.png)"]
            onAccepted: {
                if(!walletManager.saveQrCode(TxUtils.makeQRCodeString(appWindow.current_address), walletManager.urlToLocalPath(fileUrl))) {
                    console.log("Failed to save QrCode to file " + walletManager.urlToLocalPath(fileUrl) )
                    receivePageDialog.title = qsTr("Save QrCode") + translationManager.emptyString;
                    receivePageDialog.text = qsTr("Failed to save QrCode to ") + walletManager.urlToLocalPath(fileUrl) + translationManager.emptyString;
                    receivePageDialog.icon = StandardIcon.Error
                    receivePageDialog.open()
                }
            }
        }
    }

    function onPageCompleted() {
        console.log("Receive page loaded");
        subaddressListView.model = appWindow.currentWallet.subaddressModel;

        if (appWindow.currentWallet) {
            appWindow.current_address = appWindow.currentWallet.address(appWindow.currentWallet.currentSubaddressAccount, 0)
            appWindow.currentWallet.subaddress.refresh(appWindow.currentWallet.currentSubaddressAccount)
        }
    }

    function clearFields() {
        // @TODO: add fields
    }

    function onPageClosed() {
    }
}
