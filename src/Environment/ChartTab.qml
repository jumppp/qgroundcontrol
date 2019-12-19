import QtQuick          2.3
import QtQuick.Controls 1.2

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ScreenTools   1.0

Rectangle {

    QGCPalette { id: qgcPal; colorGroupEnabled: true }
    ExclusiveGroup { id: setupButtonGroup }
    color: qgcPal.windowShade

    readonly property real  _defaultTextHeight:     ScreenTools.defaultFontPixelHeight

    QGCLabel {
        anchors.margins:        _defaultTextHeight * 2
        anchors.fill:           parent
        verticalAlignment:      Text.AlignVCenter
        horizontalAlignment:    Text.AlignHCenter
        wrapMode:               Text.WordWrap
        font.pointSize:         ScreenTools.largeFontPointSize
        text:                   qsTr("请先选择飞行场次")
    }
}




