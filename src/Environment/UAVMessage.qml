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
Item{
    id:uavmessageItem

    QGCPalette { id: qgcPal }
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

Column{
    id:uavcolumn
    anchors.fill: parent

    Text {
        id: titletext
        text: qsTr("无人机信息")
        font.family: "华文中宋"
        height: unitHeight
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 20
        anchors.horizontalCenter: parent.horizontalCenter
        color: "white"
    }

    Item {
        id: functionItem
        height: unitHeight*2.3
        width: parent.width
        Item {
            id: menuitem
            anchors.top:parent.top
            anchors.left:parent.left
            width: unitWidth*1.5
            height: parent.height
        }
        Item {
            id: instrumentiItem
            anchors.left: menuitem.right
            anchors.top:parent.top
            width: unitWidth*4.7
            height: parent.height

            QGCAttitudeWidget{
                id:                 attitude
                anchors.left:       parent.left
                size:               parent.width/2-10
                vehicle:            _activeVehicle
                anchors.verticalCenter: parent.verticalCenter
            }
            QGCCompassWidget{
                id:                 compass
                anchors.left:       attitude.right
                size:               parent.width/2-10
                vehicle:            _activeVehicle
                anchors.verticalCenter: parent.verticalCenter
            }

        }

    }

    Text {

        id: flightModelText
        text: qsTr("飞行模式:Stablized")
        font.pixelSize: 15
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Item {
        id: sepLine1
        height:unitHeight*0.2
        width:unitWidth*7
        Text {
            id: geoText
            text: qsTr("位置信息")
            color: "white"
            font.family: "华文中宋"
            font.pixelSize: 10

        }
        Rectangle{
            anchors.left: geoText.right
            anchors.verticalCenter: parent.verticalCenter
            color: qgcPal.window
            width: unitWidth*5
            height: 1
        }
    }
    Item {
        id: geotextitem

        height: unitHeight
        width: parent.width
        Row{
            id:georow
            height: parent.height
            width: parent.width
            Item {
                id: emptyitem
                width: unitWidth
                height: parent.height
            }
            Item {
                id: longitem
                width: unitWidth*2
                height:parent.height
                Text {
                    id: longtext
                    height: parent.height/2
                    text: qsTr("经度:")
                }
                Text {
                    id: longvalue
                    anchors.top:longtext.bottom
                    height: parent.height/2
                    text: qsTr("120.358481")
                }

            }
            Item {
                id: latitem
                width: unitWidth*2
                height:parent.height
                Text {
                    id: lattext
                    height: parent.height/2
                    text: qsTr("纬度:")
                }
                Text {
                    id: latvalue
                    anchors.top:lattext.bottom
                    height: parent.height/2
                    text: qsTr("30.353282")
                }

            }
            Item {
                id: altitem
                width: unitWidth*2
                height:parent.height
                Text {
                    id: alttext
                    height: parent.height/2
                    text: qsTr("高度:")
                }
                Text {
                    id: altvalue
                    anchors.top:alttext.bottom
                    height: parent.height/2
                    text: qsTr("50.5"+"米")
                }

            }

        }//row

    }//geptextitem

    Item {
        id: sepLine2
        height:unitHeight*0.2
        width:unitWidth*7
        Text {
            id: posText
            text: qsTr("姿态信息")
            color: "white"
            font.family: "华文中宋"
            font.pixelSize: 10

        }
        Rectangle{
            anchors.left: posText.right
            anchors.verticalCenter: parent.verticalCenter
            color: qgcPal.window
            width: unitWidth*5
            height: 1
        }
    }
    Item {
        id: postextitem

        height: unitHeight
        width: parent.width
        Row{
            id:posrow
            height: parent.height
            width: parent.width
            Item {
                id: emptyitem2
                width: unitWidth
                height: parent.height
            }
            Item {
                id: yawitem
                width: unitWidth*2
                height:parent.height
                Text {
                    id: yawtext
                    height: parent.height/2
                    text: qsTr("偏航(Yaw)")
                }
                Text {
                    id: yawvalue
                    anchors.top:yawtext.bottom
                    height: parent.height/2
                    text: qsTr("122.4°")
                }

            }
            Item {
                id: pitchitem
                width: unitWidth*2
                height:parent.height
                Text {
                    id: pitchtext
                    height: parent.height/2
                    text: qsTr("俯仰(Pitch)")
                }
                Text {
                    id: pitchvalue
                    anchors.top:pitchtext.bottom
                    height: parent.height/2
                    text: qsTr("3.5°")
                }

            }
            Item {
                id: rollitem
                width: unitWidth*2
                height:parent.height
                Text {
                    id: rolltext
                    height: parent.height/2
                    text: qsTr("横滚(Roll)")
                }
                Text {
                    id: rollvalue
                    anchors.top:rolltext.bottom
                    height: parent.height/2
                    text: qsTr("15.8°")
                }

            }

        }//row

    }//Pos

    Item {
        id: sepLine3
        height:unitHeight*0.2
        width:unitWidth*7
        Text {
            id: flightText
            text: qsTr("飞行情况")
            color: "white"
            font.family: "华文中宋"
            font.pixelSize:10

        }
        Rectangle{
            anchors.left: flightText.right
            anchors.verticalCenter: parent.verticalCenter
            color: qgcPal.window
            width: unitWidth*5
            height: 1
        }
    }
    Item {
        id: flighttextitem
        height: unitHeight
        width: parent.width
        Row{
            id:flightrow
            height: parent.height
            width: parent.width
            Item {
                id: emptyitem3
                width: unitWidth
                height: parent.height
            }
            Item {
                id: filghttimeitem
                width: unitWidth*2
                height:parent.height
                Text {
                    id: filghttimetext
                    height: parent.height/2
                    text: qsTr("飞行时间:")
                }
                Text {
                    id: filghttimevalue
                    anchors.top:filghttimetext.bottom
                    height: parent.height/2
                    text: qsTr("3min15s")
                }

            }
            Item {
                id: groundspeeditem
                width: unitWidth*2
                height:parent.height
                Text {
                    id: groundspeedtext
                    height: parent.height/2
                    text: qsTr("地速:")
                }
                Text {
                    id: groundspeedvalue
                    anchors.top:groundspeedtext.bottom
                    height: parent.height/2
                    text: qsTr("3.5"+"m/s")
                }

            }
            Item {
                id: climbspeeditem
                width: unitWidth*2
                height:parent.height
                Text {
                    id: climbspeedtext
                    height: parent.height/2
                    text: qsTr("上升速度:")
                }
                Text {
                    id: climbspeedvalue
                    anchors.top:climbspeedtext.bottom
                    height: parent.height/2
                    text: qsTr("1.2"+"m/s")
                }

            }

        }//row

    }//flight

    }
}
