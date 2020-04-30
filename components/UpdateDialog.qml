// Copyright (c) 2020, The Monero Project
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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import bittubeComponents.Downloader 1.0

import "../components" as BittubeComponents

Popup {
    id: updateDialog

    property bool allowed: true
    property string error: ""
    property string filename: ""
    property double progress: url && downloader.total > 0 ? downloader.loaded * 100 / downloader.total : 0
    property bool active: false
    property string url: ""
    property bool valid: false
    property string version: ""

    background: Rectangle {
        border.color: BittubeComponents.Style.appWindowBorderColor
        border.width: 1
        color: BittubeComponents.Style.middlePanelBackgroundColor
    }
    closePolicy: Popup.NoAutoClose
    padding: 20
    visible: active && allowed

    function show(version, url) {
        updateDialog.error = "";
        updateDialog.url = url;
        updateDialog.valid = false;
        updateDialog.version = version;
        updateDialog.active = true;
    }

    ColumnLayout {
        id: mainLayout
        spacing: updateDialog.padding

        Text {
            color: BittubeComponents.Style.defaultFontColor
            font.bold: true
            font.family: BittubeComponents.Style.fontRegular.name
            font.pixelSize: 18
            text: qsTr("New Monero version v%1 is available.").arg(updateDialog.version)
        }

        Text {
            id: errorText
            color: "red"
            font.family: BittubeComponents.Style.fontRegular.name
            font.pixelSize: 18
            text: updateDialog.error
            visible: text
        }

        Text {
            id: statusText
            color: BittubeComponents.Style.defaultFontColor
            font.family: BittubeComponents.Style.fontRegular.name
            font.pixelSize: 18
            visible: !errorText.visible

            text: {
                if (!updateDialog.url) {
                    return qsTr("Please visit getbittube.org for details") + translationManager.emptyString;
                }
                if (downloader.active) {
                    return "%1 (%2%)"
                        .arg(qsTr("Downloading"))
                        .arg(updateDialog.progress.toFixed(1))
                        + translationManager.emptyString;
                }
                if (updateDialog.valid) {
                    return qsTr("Download finished") + translationManager.emptyString;
                }
                return qsTr("Do you want to download new version?") + translationManager.emptyString;
            }
        }

        Rectangle {
            id: progressBar
            color: BittubeComponents.Style.lightGreyFontColor
            height: 3
            Layout.fillWidth: true
            visible: updateDialog.valid || downloader.active

            Rectangle {
                color: BittubeComponents.Style.buttonBackgroundColor
                height: parent.height
                width: parent.width * updateDialog.progress / 100
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: parent.spacing

            BittubeComponents.StandardButton {
                id: cancelButton
                fontBold: false
                primary: !updateDialog.url
                text: {
                    if (!updateDialog.url) {
                        return qsTr("Ok") + translationManager.emptyString;
                    }
                    if (updateDialog.valid || downloader.active || errorText.visible) {
                        return qsTr("Cancel")  + translationManager.emptyString;
                    }
                    return qsTr("Download later") + translationManager.emptyString;
                }

                onClicked: {
                    downloader.cancel();
                    updateDialog.active = false;
                }
            }

            BittubeComponents.StandardButton {
                id: downloadButton
                KeyNavigation.tab: cancelButton
                fontBold: false
                text: (updateDialog.error ? qsTr("Retry") : qsTr("Download")) + translationManager.emptyString
                visible: updateDialog.url && !updateDialog.valid && !downloader.active

                onClicked: {
                    updateDialog.error = "";
                    updateDialog.filename = updateDialog.url.replace(/^.*\//, '');
                    const downloadingStarted = downloader.get(updateDialog.url, function(error) {
                        if (error) {
                            updateDialog.error = qsTr("Download failed") + translationManager.emptyString;
                        } else {
                            updateDialog.valid = true;
                        }
                    });
                    if (!downloadingStarted) {
                        updateDialog.error = qsTr("Failed to start download") + translationManager.emptyString;
                    }
                }
            }

            BittubeComponents.StandardButton {
                id: saveButton
                KeyNavigation.tab: cancelButton
                fontBold: false
                onClicked: {
                    const fullPath = oshelper.openSaveFileDialog(
                        qsTr("Save as") + translationManager.emptyString,
                        oshelper.downloadLocation(),
                        updateDialog.filename);
                    if (!fullPath) {
                        return;
                    }
                    if (downloader.saveToFile(fullPath)) {
                        cancelButton.clicked();
                        oshelper.openContainingFolder(fullPath);
                    } else {
                        updateDialog.error = qsTr("Save operation failed") + translationManager.emptyString;
                    }
                }
                text: qsTr("Save to file") + translationManager.emptyString
                visible: updateDialog.valid
            }
        }
    }

    Downloader {
        id: downloader
    }
}
