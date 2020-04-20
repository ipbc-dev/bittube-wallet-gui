import QtQuick 2.9

import "../components" as BittubeComponents

TextEdit {
    color: BittubeComponents.Style.defaultFontColor
    font.family: BittubeComponents.Style.fontRegular.name
    selectionColor: BittubeComponents.Style.textSelectionColor
    wrapMode: Text.Wrap
    readOnly: true
    selectByMouse: true
    // Workaround for https://bugreports.qt.io/browse/QTBUG-50587
    onFocusChanged: {
        if(focus === false)
            deselect()
    }
}
