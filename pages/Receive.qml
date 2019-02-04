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

import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import "../components" as MoneroComponents
import moneroComponents.Clipboard 1.0
import moneroComponents.Wallet 1.0
import moneroComponents.WalletManager 1.0
import moneroComponents.TransactionHistory 1.0
import moneroComponents.TransactionHistoryModel 1.0
import moneroComponents.Subaddress 1.0
import moneroComponents.SubaddressModel 1.0
import "../js/TxUtils.js" as TxUtils

Rectangle {
    id: pageReceive
    color: "transparent"
    property var model
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
        inputDialog.inputText = appWindow.currentWallet.getSubaddressLabel(appWindow.currentWallet.currentSubaddressAccount, _index);
        inputDialog.onAcceptedCallback = function() {
            appWindow.currentWallet.subaddress.setLabel(appWindow.currentWallet.currentSubaddressAccount, _index, inputDialog.inputText);
        }
        inputDialog.onRejectedCallback = null;
        inputDialog.open()
    }

    Clipboard { id: clipboard }

    /* main layout */
    ColumnLayout {
        id: mainLayout
        anchors.margins: (isMobile)? 17 * scaleRatio : 20 * scaleRatio
        anchors.topMargin: 40 * scaleRatio

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 20 * scaleRatio
        property int labelWidth: 120 * scaleRatio
        property int editWidth: 400 * scaleRatio
        property int lineEditFontSize: 12 * scaleRatio
        property int qrCodeSize: 220 * scaleRatio

        ColumnLayout {
            id: addressRow
            spacing: 0

            MoneroComponents.LabelSubheader {
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: "<style type='text/css'>a {text-decoration: none; color: #86af49; font-size: 14px;}</style>" +
                      qsTr("Addresses") +
                      "<font size='2'> </font><a href='#'>" +
                      qsTr("Help") + "</a>" +
                      translationManager.emptyString
                onLinkActivated: {
                    receivePageDialog.title  = qsTr("Tracking payments") + translationManager.emptyString;
                    receivePageDialog.text = qsTr(
                        "<p>This QR code includes the address you selected above and" +
                        "the amount you entered below. Share it with others (right-click->Save) " +
                        "so they can more easily send you exact amounts.</p>"
                    )
                    receivePageDialog.icon = StandardIcon.Information
                    receivePageDialog.open()
                }
            }

            ColumnLayout {
                id: subaddressListRow
                property int subaddressListItemHeight: 32 * scaleRatio
                Layout.topMargin: 22 * scaleRatio
                Layout.fillWidth: true
                Layout.minimumWidth: 240
                Layout.preferredHeight: subaddressListItemHeight * subaddressListView.count
                visible: subaddressListView.count >= 1

                ListView {
                    id: subaddressListView
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    clip: true
                    boundsBehavior: ListView.StopAtBounds
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
                            color: "#404040"
                            visible: index !== 0
                        }

                        Rectangle {
                            anchors.fill: parent
                            anchors.topMargin: 5
                            anchors.rightMargin: 80
                            color: "transparent"

                            MoneroComponents.Label {
                                id: idLabel
                                color: index === appWindow.current_subaddress_table_index ? "#464646" : "#757575"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 6
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: "#" + index
                            }

                            MoneroComponents.Label {
                                id: nameLabel
                                color: "#a5a5a5"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: idLabel.right
                                anchors.leftMargin: 6
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: label
                            }

                            MoneroComponents.Label {
                                color: "#464646"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: nameLabel.right
                                anchors.leftMargin: 6
                                fontSize: 14 * scaleRatio
                                fontBold: true
                                text: {
                                    if(isMobile){
                                        TxUtils.addressTruncate(address, 6);
                                    } else {
                                        return TxUtils.addressTruncate(address, 10);
                                    }
                                }
                            }

                            MouseArea{
                                cursorShape: Qt.PointingHandCursor
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    tableItem2.color = "#26FFFFFF"
                                }
                                onExited: {
                                    tableItem2.color = "transparent"
                                }
                                onClicked: {
                                    subaddressListView.currentIndex = index;
                                }
                            }
                        }

                        MoneroComponents.IconButton {
                            id: renameButton
                            imageSource: "../images/editIcon.png"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: index !== 0 ? copyButton.left : parent.right
                            anchors.rightMargin: index !== 0 ? 0 : 6
                            anchors.top: undefined
                            visible: index !== 0

                            onClicked: {
                                renameSubaddressLabel(index);
                            }
                        }

                        MoneroComponents.IconButton {
                            id: copyButton
                            imageSource: "../images/copyToClipboard.png"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.top: undefined
                            anchors.right: parent.right

                            onClicked: {
                                console.log("Address copied to clipboard");
                                clipboard.setText(address);
                                appWindow.showStatusMessage(qsTr("Address copied to clipboard"),3);
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

            // 'fake' row for 'create new address'
            ColumnLayout {
                id: createAddressRow
                Layout.fillWidth: true
                spacing: 0

                Rectangle {
                    color: "#404040"
                    Layout.fillWidth: true
                    height: 1
                }

                Rectangle {
                    id: createAddressRect
                    Layout.preferredHeight: subaddressListRow.subaddressListItemHeight
                    color: "transparent"
                    Layout.fillWidth: true

                    MoneroComponents.Label {
                        id: createAddressLabel
                        color: "#757575"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 6
                        fontSize: 14 * scaleRatio
                        fontBold: true
                        text: "+ " + qsTr("Create new address") + translationManager.emptyString;
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: {
                            createAddressRect.color = "#26FFFFFF"
                        }
                        onExited: {
                            createAddressRect.color = "transparent"
                        }
                        onClicked: {
                            inputDialog.labelText = qsTr("Set the label of the new address:") + translationManager.emptyString
                            inputDialog.inputText = qsTr("(Untitled)")
                            inputDialog.onAcceptedCallback = function() {
                                appWindow.currentWallet.subaddress.addRow(appWindow.currentWallet.currentSubaddressAccount, inputDialog.inputText)
                                current_subaddress_table_index = appWindow.currentWallet.numSubaddresses(appWindow.currentWallet.currentSubaddressAccount) - 1
                            }
                            inputDialog.onRejectedCallback = null;
                            inputDialog.open()
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 11 * scaleRatio
            property int qrSize: 220 * scaleRatio

            Rectangle {
                id: qrContainer
                color: "white"
                Layout.fillWidth: true
                spacing: 20 * scaleRatio

                LabelSubheader {
                    Layout.fillWidth: true
                    textFormat: Text.RichText
                    text: "<style type='text/css'>a {text-decoration: none; color: #86af49; font-size: 14px;}</style>" +
                          qsTr("QR Code") +
                          "<font size='2'> </font><a href='#'>" +
                          qsTr("Help") + "</a>" +
                          translationManager.emptyString
                    onLinkActivated: {
                        receivePageDialog.title  = qsTr("QR Code") + translationManager.emptyString;
                        receivePageDialog.text = qsTr(
                            "<p>This QR code includes the address you selected above and " +
                            "the amount you entered below. Share it with others (right-click->Save) " +
                            "so they can more easily send you exact amounts.</p>"
                        )
                        receivePageDialog.icon = StandardIcon.Information
                        receivePageDialog.open()
                    }
                }
                Layout.maximumWidth: parent.qrSize
                Layout.preferredHeight: width
                radius: 4 * scaleRatio

                Image {
                    id: qrCode
                    anchors.fill: parent
                    anchors.margins: 1 * scaleRatio

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

            ColumnLayout {
                id: trackingRow
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                spacing: 0 * scaleRatio

                LabelSubheader {
                    Layout.fillWidth: true
                    textFormat: Text.RichText
                    text: "<style type='text/css'>a {text-decoration: none; color: #86af49; font-size: 14px;}</style>" +
                          qsTr("Tracking") +
                          "<font size='2'> </font><a href='#'>" +
                          qsTr("Help") + "</a>" +
                          translationManager.emptyString
                    onLinkActivated: {
                        receivePageDialog.title  = qsTr("Tracking payments") + translationManager.emptyString;
                        receivePageDialog.text = qsTr(
                            "<p><font size='+2'>This is a simple sales tracker:</font></p>" +
                            "<p>Let your customer scan that QR code to make a payment (if that customer has software which " +
                            "supports QR code scanning).</p>" +
                            "<p>This page will automatically scan the blockchain and the tx pool " +
                            "for incoming transactions using this QR code. If you input an amount, it will also check " +
                            "that incoming transactions total up to that amount.</p>" +
                            "<p>It's up to you whether to accept unconfirmed transactions or not. It is likely they'll be " +
                            "confirmed in short order, but there is still a possibility they might not, so for larger " +
                            "values you may want to wait for one or more confirmation(s).</p>"
                        )
                        receivePageDialog.icon = StandardIcon.Information
                        receivePageDialog.open()
                    }
                }

                MoneroComponents.StandardButton {
                    rightIcon: "../images/download-white.png"
                    onClicked: qrFileDialog.open()
                }

                MoneroComponents.StandardButton {
                    rightIcon: "../images/external-link-white.png"
                    onClicked: {
                        clipboard.setText(TxUtils.makeQRCodeString(appWindow.current_address));
                        appWindow.showStatusMessage(qsTr("Copied to clipboard"), 3);
                    }
                }
            }
        }

        MessageDialog {
            id: receivePageDialog
            standardButtons: StandardButton.Ok
        }

        FileDialog {
            id: qrFileDialog
            title: qsTr("Please choose a name")
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
    }

    function onPageClosed() {
    }
}
