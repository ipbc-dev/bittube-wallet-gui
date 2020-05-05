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
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.2

import FontAwesome 1.0
import "." as BittubeComponents
import "effects/" as MoneroEffects

Rectangle {
    id: root
    property int mouseX: 0
    property bool customDecorations: persistentSettings.customDecorations
    property bool showMinimizeButton: true
    property bool showMaximizeButton: true
    property bool showCloseButton: true
    property string walletName: ""

    height: {
        if(!persistentSettings.customDecorations) return 0;
        return 50;
    }

    z: 1
    color: "transparent"

    signal closeClicked
    signal maximizeClicked
    signal minimizeClicked
    signal languageClicked
    signal closeWalletClicked

    state: "default"
    states: [
        State {
            name: "default";
            PropertyChanges { target: btnCloseWallet; visible: true}
            PropertyChanges { target: btnLanguageToggle; visible: true}
        }, State {
            // show only theme switcher and window controls
            name: "essentials";
            PropertyChanges { target: btnCloseWallet; visible: false}
            PropertyChanges { target: btnLanguageToggle; visible: false}
        }
    ]

    MoneroEffects.GradientBackground {
        anchors.fill: parent
        duration: 300
        fallBackColor: BittubeComponents.Style.middlePanelBackgroundColor
        initialStartColor: BittubeComponents.Style.titleBarBackgroundGradientStart
        initialStopColor: BittubeComponents.Style.titleBarBackgroundGradientStop
        blackColorStart: BittubeComponents.Style._b_titleBarBackgroundGradientStart
        blackColorStop: BittubeComponents.Style._b_titleBarBackgroundGradientStop
        whiteColorStart: BittubeComponents.Style._w_titleBarBackgroundGradientStart
        whiteColorStop: BittubeComponents.Style._w_titleBarBackgroundGradientStop
        start: Qt.point(width, 0)
        end: Qt.point(0, 0)
    }

    RowLayout {
        z: parent.z + 2
        spacing: 0
        anchors.fill: parent

        // collapse sidebar
        Rectangle {
            id: btnCloseWallet
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height


            Text {
                text: FontAwesome.signOutAlt
                font.family: FontAwesome.fontFamilySolid
                font.pixelSize: 16
                color: BittubeComponents.Style.defaultFontColor
                font.styleName: "Solid"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.75
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: parent.color = BittubeComponents.Style.titleBarButtonHoverColor
                onExited: parent.color = "transparent"
                onClicked: root.closeWalletClicked(leftPanel.visible)
            }
        }

        // language selection
        Rectangle {
            id: btnLanguageToggle
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            Text {
                text: FontAwesome.globe
                font.family: FontAwesome.fontFamilySolid
                font.pixelSize: 16
                color: BittubeComponents.Style.defaultFontColor
                font.styleName: "Solid"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.75
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: parent.color = BittubeComponents.Style.titleBarButtonHoverColor
                onExited: parent.color = "transparent"
                onClicked: root.languageClicked()
            }
        }

        // switch theme
        Rectangle {
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            Text {
                text: FontAwesome.moonO
                font.family: BittubeComponents.Style.blackTheme ? FontAwesome.fontFamilySolid : FontAwesome.fontFamily
                font.styleName: BittubeComponents.Style.blackTheme ? "Solid" : "Regular"
                font.pixelSize: 15
                color: BittubeComponents.Style.defaultFontColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.75
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: parent.color = BittubeComponents.Style.titleBarButtonHoverColor
                onExited: parent.color = "transparent"
                onClicked: {
                    BittubeComponents.Style.blackTheme = !BittubeComponents.Style.blackTheme;
                    persistentSettings.blackTheme = BittubeComponents.Style.blackTheme;
                }
            }
        }

        Item {
            // make dummy space when hiding buttons when titlebar
            // state is 'essentials' in order for the
            // bittube logo to still be centered
            Layout.preferredWidth: parent.height * 2  // amount of buttons we hide
            Layout.preferredHeight: parent.height
            visible: root.state == "essentials"
        }

        // bittube logo
        Item {
            visible: walletName.length === 0
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height

            Image {
                id: imgLogo
                width: 125
                height: 28

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                source: BittubeComponents.Style.titleBarLogoSource
                visible: {
                    if(!isOpenGL) return true;
                    if(!BittubeComponents.Style.blackTheme) return true;
                    return false;
                }
            }

            Colorize {
                visible: isOpenGL && BittubeComponents.Style.blackTheme
                anchors.fill: imgLogo
                source: imgLogo
                saturation: 0.0
            }
        }

        Item {
            visible: walletName.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height

            BittubeComponents.TextPlain {
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                width: parent.width
                height: parent.height
                elide: Text.ElideRight
                text: walletName
            }
        }

        // minimize
        Rectangle {
            color: "transparent"
            visible: root.showMinimizeButton
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            MoneroEffects.ImageMask {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 18
                anchors.horizontalCenter: parent.horizontalCenter
                height: 3
                width: 15
                image: BittubeComponents.Style.titleBarMinimizeSource
                color: BittubeComponents.Style.defaultFontColor
                fontAwesomeFallbackIcon: FontAwesome.minus
                fontAwesomeFallbackSize: 18
                fontAwesomeFallbackOpacity: BittubeComponents.Style.blackTheme ? 0.8 : 0.6
                opacity: 0.75
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: parent.color = BittubeComponents.Style.titleBarButtonHoverColor
                onExited: parent.color = "transparent"
                onClicked: root.minimizeClicked();
            }
        }

        // maximize
        Rectangle {
            id: test
            visible: root.showMaximizeButton
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                source: BittubeComponents.Style.titleBarFullscreenSource
                sourceSize.width: 16
                sourceSize.height: 16
                smooth: true
                mipmap: true
                opacity: 0.75
                rotation: appWindow.visibility === Window.FullScreen ? 180 : 0
            }

            MouseArea {
                id: buttonArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: parent.color = BittubeComponents.Style.titleBarButtonHoverColor
                onExited: parent.color = "transparent"
                onClicked: root.maximizeClicked();
            }
        }

        // close
        Rectangle {
            visible: root.showCloseButton
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            MoneroEffects.ImageMask {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                height: 16
                width: 16
                image: BittubeComponents.Style.titleBarCloseSource
                color: BittubeComponents.Style.defaultFontColor
                fontAwesomeFallbackIcon: FontAwesome.times
                fontAwesomeFallbackSize: 21
                fontAwesomeFallbackOpacity: BittubeComponents.Style.blackTheme ? 0.8 : 0.6
                opacity: 0.75
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: parent.color = BittubeComponents.Style.titleBarButtonHoverColor
                onExited: parent.color = "transparent"
                onClicked: root.closeClicked();
            }
        }
    }

    Rectangle {
        z: parent.z + 3
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: BittubeComponents.Style.blackTheme ? 1 : 1
        color: BittubeComponents.Style.titleBarBackgroundBorderColor

        MoneroEffects.ColorTransition {
            targetObj: parent
            blackColor: BittubeComponents.Style._b_titleBarBackgroundBorderColor
            whiteColor: BittubeComponents.Style._w_titleBarBackgroundBorderColor
        }
    }

    MouseArea {
        enabled: persistentSettings.customDecorations
        property var previousPosition
        anchors.fill: parent
        propagateComposedEvents: true
        onPressed: previousPosition = globalCursor.getPosition()
        onPositionChanged: {
            if (pressedButtons == Qt.LeftButton) {
                var pos = globalCursor.getPosition()
                var dx = pos.x - previousPosition.x
                var dy = pos.y - previousPosition.y

                appWindow.x += dx
                appWindow.y += dy
                previousPosition = pos
            }
        }
    }
}
