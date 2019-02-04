pragma Singleton

import QtQuick 2.5

QtObject {
    property QtObject fontMedium: FontLoader { id: _fontMedium; source: "qrc:/fonts/Roboto-Medium.ttf"; }
    property QtObject fontBold: FontLoader { id: _fontBold; source: "qrc:/fonts/Roboto-Bold.ttf"; }
    property QtObject fontLight: FontLoader { id: _fontLight; source: "qrc:/fonts/Roboto-Light.ttf"; }
    property QtObject fontRegular: FontLoader { id: _fontRegular; source: "qrc:/fonts/Roboto-Regular.ttf"; }

    property string grey:                                   "#404040"
    property string legacy_placeholderFontColor:            "#BABABA"
    property string orange:                                 "#FF6C3C"
    property string white:                                  "#FFFFFF"
    property string green:                                  "#2EB358"
    property string moneroGrey:                             "#4C4C4C"
    property string errorColor:                             "#FA6800"
    //font
    property string defaultFontColor:                       "#464646"
    property string greyFontColor:                          "#808080"
    property string dimmedFontColor:                        "#BBBBBB"
    //inputBox
    property string inputBoxBackground:                     "#000000"
    property string inputBoxBackgroundError:                "#ffdddd"
    property string inputBoxColor:                          "#ffffff"
    //input
    property string inputBorderColorActive:                 "#464646"
    property string inputBorderColorInActive:               "#404040"
    property string inputBorderColorInvalid:                "#ff0000"
    property string inputBackgroundColor:                   "#ffffff"
    //button
    property string buttonBackgroundColor:                  "#86af49"
    property string buttonBackgroundColorHover:             "#b0e660"
    property string buttonBackgroundColorDisabled:          "#BABABA"
    property string buttonBackgroundColorDisabledHover:     "#808080"
    property string buttonTextColor:                        "#ffffff"
    property string buttonTextColorDisabled:                "#464646"
    //divider
    property string dividerColor:                           "#d2d2d2"
    property real dividerOpacity:                           1
    //progressbar
    property string progressbarBackgroundColor:             "#86af49"
    //datepicker
    property string datepickerBackgroundColor:              "#ffffff"
    property string datepickerBorderColor:                  "#404040"
    //dropdown
    property string dropdownContentBackgroundColor:         "#ffffff"
    property string dropdownContentFontColor:               "#404040"
    property string dropdownContentSelectedBackgroundColor: "#ffffff"
    property string dropdownContentSelectedFontColor:       "#86af49"
    property string dropdownHeaderBackgroundColor:          "#ffffff"
    //calendar
    property string calendarSelectedBackgroundColor:        "#86af49"
    //notifier
    property string notifierBackgroundColor:                "#ffffff"
    property string notifierFontColor:                      "#464646"
    //privacyLevel
    property string privacyLevelBackgroundColor:            "#ffffff"
    property string privacyLevelBarColor:                   "#86af49"
    //radiobutton
    property string radiobuttonCheckedColor:                "#464646"
    property string radiobuttonBorderColor:                 "#464646"
    //lineEdit
    property string lineEditBackgroundColor:                "#ffffff"
    //lineEditMulti
    property string lineEditMultiBackgroundColor:           "#ffffff"
    //searchInput
    property string searchInputBackgroundColor:             "#ffffff"
    //passwordDialog
    property string passwordDialogBackgroundColor:          "#ffffff"
    property string passwordDialogHeaderFontColor:          "#ffffff"
}
