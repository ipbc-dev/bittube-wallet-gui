pragma Singleton

import QtQuick 2.5

QtObject {
    property QtObject fontMedium: FontLoader { id: _fontMedium; source: "qrc:/fonts/SFUIDisplay-Medium.otf"; }
    property QtObject fontBold: FontLoader { id: _fontBold; source: "qrc:/fonts/SFUIDisplay-Bold.otf"; }
    property QtObject fontLight: FontLoader { id: _fontLight; source: "qrc:/fonts/SFUIDisplay-Light.otf"; }
    property QtObject fontRegular: FontLoader { id: _fontRegular; source: "qrc:/fonts/SFUIDisplay-Regular.otf"; }

    property string grey: "#404040"
    property string legacy_placeholderFontColor: "#BABABA"

    //font
    property string defaultFontColor: "#464646"
    property string greyFontColor: "#808080"
    property string dimmedFontColor: "#BBBBBB"

    //inputBox
    property string inputBoxBackground: "black"
    property string inputBoxBackgroundError: "#FFDDDD"
    property string inputBoxColor: "white"

    //input
    property string inputBorderColorActive: Qt.rgba(100, 100, 100, 1)
    property string inputBorderColorInActive: Qt.rgba(100, 100, 100, 1)
    property string inputBorderColorInvalid: Qt.rgba(255, 0, 0, 1)

    //button
    property string buttonBackgroundColor: "#86af49"
    property string buttonBackgroundColorHover: "#b0e660"
    property string buttonBackgroundColorDisabled: "#8b8b8b"
    property string buttonBackgroundColorDisabledHover: "#808080"
    property string buttonTextColor: "#ffffff"
    property string buttonTextColorDisabled: "#464646"
    
    //divider
    property string dividerColor: "black"
    property real dividerOpacity: 0.20

    //progressbar
    property string progressbarBackgroundColor: "#86af49"
}
