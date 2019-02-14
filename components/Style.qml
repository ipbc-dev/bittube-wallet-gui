pragma Singleton

import QtQuick 2.5

QtObject {
    property QtObject fontMedium: FontLoader { id: _fontMedium; source: "qrc:/fonts/Roboto-Medium.ttf"; }
    property QtObject fontBold: FontLoader { id: _fontBold; source: "qrc:/fonts/Roboto-Bold.ttf"; }
    property QtObject fontLight: FontLoader { id: _fontLight; source: "qrc:/fonts/Roboto-Light.ttf"; }
    property QtObject fontRegular: FontLoader { id: _fontRegular; source: "qrc:/fonts/Roboto-Regular.ttf"; }

    property string background:                             "#ffffff"
    property string grey:                                   "#404040"
    property string legacy_placeholderFontColor:            "#BABABA"
    property string orange:                                 "#FF6C3C"
    property string white:                                  "#FFFFFF"
    property string green:                                  "#2EB358"
    property string blue:                                   "#00abff"
    property string moneroGrey:                             "#4C4C4C"
    property string errorColor:                             "#FA6800"
    //font
    property string defaultFontColor:                       "#343434"
    property string greyFontColor:                          "#808080"
    property string dimmedFontColor:                        "#BBBBBB"
    property string highlitedFontColor:                     "#00abff"
    //inputBox
    property string inputBoxBackground:                     "#000000"
    property string inputBoxBackgroundError:                "#ffdddd"
    property string inputBoxColor:                          "#eeeeee"
    //input
    property string inputBorderColorActive:                 "#343434"
    property string inputBorderColorInActive:               "#404040"
    property string inputBorderColorInvalid:                "#ff0000"
    property string inputBackgroundColor:                   "#eeeeee"
    //button
    property string buttonBackgroundColor:                  "#00abff"
    property string buttonBackgroundColorHover:             "#57c8ff"
    property string buttonBackgroundColorDisabled:          "#BABABA"
    property string buttonBackgroundColorDisabledHover:     "#808080"
    property string buttonTextColor:                        "#ffffff"
    property string buttonTextColorDisabled:                "#343434"
    //divider
    property string dividerColor:                           "#d2d2d2"
    property real dividerOpacity:                           1
    //progressbar
    property string progressbarBackgroundColor:             "#00abff"
    //datepicker
    property string datepickerBackgroundColor:              "#eeeeee"
    property string datepickerBorderColor:                  "#404040"
    //dropdown
    property string dropdownContentBackgroundColor:         "#eeeeee"
    property string dropdownContentFontColor:               "#404040"
    property string dropdownContentSelectedBackgroundColor: "#ffffff"
    property string dropdownContentSelectedFontColor:       "#00abff"
    property string dropdownHeaderBackgroundColor:          "#eeeeee"
    //calendar
    property string calendarSelectedBackgroundColor:        "#00abff"
    //notifier
    property string notifierBackgroundColor:                "#ffffff"
    property string notifierFontColor:                      "#343434"
    //privacyLevel
    property string privacyLevelBackgroundColor:            "#ffffff"
    property string privacyLevelBarColor:                   "#00abff"
    //radiobutton
    property string radiobuttonCheckedColor:                "#343434"
    property string radiobuttonBorderColor:                 "#343434"
    //lineEdit
    property string lineEditBackgroundColor:                "#eeeeee"
    //lineEditMulti
    property string lineEditMultiBackgroundColor:           "#ffffff"
    //searchInput
    property string searchInputBackgroundColor:             "#eeeeee"
    //passwordDialog
    property string passwordDialogBackgroundColor:          "#eeeeee"
    property string passwordDialogHeaderFontColor:          "#ffffff"
    //tooltip
    property string tooltipBackgroundColor:                 "#00abff"
    //leftpanel
    property string dotColor:                               "#00abff"
    //wizard
    property string navButtonColor:                         "#00abff"
    property string navButtonHoverColor:                    "#57c8ff"
    property string navButtonDisabledColor:                 "#DBDBDB"

}
