import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QtCharts         2.2
import QtQuick.Window   2.0
import QGroundControl                       1.0
import QGroundControl.Controllers           1.0
import QGroundControl.AutoPilotPlugin       1.0
import QGroundControl.Palette               1.0
import QGroundControl.FlightMap             1.0
import QtQuick.Controls 2.3
import QtQml            2.2
import QGroundControl                       1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.FactSystem    1.0
Rectangle{
    id:uavmessagerec

    color:"#C6C2C6"
    opacity: 0.8
    radius: 6
    QGCPalette {id: qgcPal }

    property real   _innerRadius:       (width - (_topBottomMargin * 3)) / 4
    property real   _outerRadius:       _innerRadius + _topBottomMargin
    property real   _defaultSize:       ScreenTools.defaultFontPixelHeight * (9)
    property real   _sizeRatio:         ScreenTools.isTinyScreen ? (width / _defaultSize) * 0.5 : width / _defaultSize
    property real   _bigFontSize:       ScreenTools.defaultFontPointSize * 2.5  * _sizeRatio
    property real   _normalFontSize:    ScreenTools.defaultFontPointSize * 1.5  * _sizeRatio
    property real   _labelFontSize:     ScreenTools.defaultFontPointSize * 0.75 * _sizeRatio
    property real   _spacing:           ScreenTools.defaultFontPixelHeight * 0.33
    property real   _topBottomMargin:   (width * 0.05) / 2

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property var unitWidth: parent.width/7
    property var unitHeight: parent.height/7.3
    property bool _first: true



        Item {
            id: menuitem
            anchors.top:parent.top
            anchors.topMargin: unitHeight
            anchors.left:parent.left
            width: unitWidth*1.6
            height: parent.height
            ExclusiveGroup { id: uavButtonGroup }

            Item {
                id:menu
                width:unitWidth
                anchors.left: parent.left
                Column {
                    id:         buttonColumn
                    anchors.left: parent.left
                    height:  30
                    Repeater {
                        id: buttonRepeater
                        model: ListModel {
                            ListElement {
                                buttonText:         qsTr("基本信息")
                                pageSource:         "UAVMessage.qml"
                            }
                            ListElement {
                                buttonText:         qsTr("电池")
                                pageSource:         "BatteryMessage.qml"
                            }
                            ListElement {
                                buttonText:         qsTr("遥控器")
                                pageSource:         "remoteControl.qml"
                            }
                        }


                        QGCButton {
                            exclusiveGroup:     uavButtonGroup
                            text:               buttonText
                            pointSize:8
                            width:  40
                            onClicked:{
                                if(uavMessageLoader.source != pageSource) {
                                    uavMessageLoader.source = pageSource
                                }
                                checked = true
                            }

                            Component.onCompleted: {
                                if(_first) {
                                    _first = false
                                    checked = true
                                }
                        }
                    }
                }

            }
        }





}

        Loader{
            id:uavMessageLoader
            anchors.fill: parent
            source: "UAVMessage.qml"
        }

}
