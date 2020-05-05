import QtQuick 2.9

import "." as BittubeComponents
import "effects/" as MoneroEffects

Rectangle {
    color: BittubeComponents.Style.appWindowBorderColor
    height: 1

    MoneroEffects.ColorTransition {
        targetObj: parent
        blackColor: BittubeComponents.Style._b_appWindowBorderColor
        whiteColor: BittubeComponents.Style._w_appWindowBorderColor
    }
}
