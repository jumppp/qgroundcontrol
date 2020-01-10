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

Item{
    id:uavcolumnItem
    anchors.fill: parent

    Text {
        id: titletext
        text: qsTr("电池信息")
        font.family: "华文中宋"
        height: unitHeight
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 20
        anchors.horizontalCenter: parent.horizontalCenter
        color: "white"
    }
    Item {
        id: emptyitem1
        anchors.left: parent.left
        anchors.top:titletext.bottom
        width: 1.5*unitWidth
        height: 6*unitHeight
    }
    Item {
        id: rightItem
        anchors.left:emptyitem1.right
        anchors.top:titletext.bottom
        height: unitHeight*6
        width: unitWidth*5.5
        Column{
            id: batteryItemCol

            width: parent.width
            height: parent.height
            Item {
                id: emptyItem2
                height: 0.4*unitHeight
                width: parent.width

            }
            Item {
                id: batteryValueItem
                height: unitHeight
                width: parent.height
                Row{
                    id:batteryValueRow
                    height: parent.height
                    width: parent.width
                    Text {
                        id: batteryText
                        width:1.5*unitWidth
                        text: qsTr("电池电压")
                        font.pointSize: 10
                        font.family: "华文中宋"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item{
                        id:batteryitem
                        width:4*unitWidth
                        height: parent.height*0.95
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle{
                            id: batteryRect3
                            anchors.centerIn: parent
                            width: parent.width*0.65
                            height: parent.height
                            radius: 2.5
                            border.width: 4
                            border.color: "lightgray"
                            //anchors.horizontalCenter: parent.horizontalCenter
                            Rectangle{
                                id: powerRect3
                                anchors.left: parent.left
                                anchors.leftMargin: parent.width*0.05
                                anchors.top: parent.top
                                anchors.topMargin: parent.width*0.05
                                width: parent.width*0.9
                                height: parent.height*0.7
                                color: "black"

                                Rectangle{
                                    id: powerRect4
                                    anchors.left: parent.left
                                    anchors.leftMargin: parent.width*0.03
                                    anchors.top: parent.top
                                    anchors.topMargin: parent.width*0.03
                                    radius: 2
                                    width: parent.width*0.7                 //调节电池电压
                                    height: parent.height-parent.width*0.06
                                    color: "green"
                                }
                            }

                            /*左侧百分百*/
                            Text{
                                anchors.left: parent.left
                                anchors.leftMargin: 0.125*parent.width
                                anchors.top: parent.top
                                anchors.topMargin: 0.125*parent.width
                                width: 0.25*batteryRect3.width
                                height: 0.4*batteryRect3.height
                                font.family: "微软雅黑"
                                font.pixelSize: 12
                                color: "white"
                                text: "70" + "%"
                            }
                            /*分隔线*/
                            Rectangle{
                                id: lineRect
                                anchors.centerIn: parent
                                height: 0.45*batteryRect3.height
                                width: 1
                                color: "white"
                            }

                            /*右下电压*/
                            Text{
                                anchors.left: lineRect.right
                                anchors.leftMargin: 0.12*parent.width
                                anchors.top: parent.top
                                anchors.topMargin: 0.3*parent.height
                                width: 15
                                font.family: "微软雅黑"
                                font.pixelSize: 10
                                color: "white"
                                text: "15.6"+ "V"
                            }

                        }
                        Rectangle{
                            anchors.left: batteryRect3.right
                            width: 0.06*batteryRect3.width
                            height: 0.37*batteryRect3.height
                            radius: 1
                            anchors.verticalCenter: parent.verticalCenter
                            //y: parent.height/2 - 6
                            color: "lightgray"
                        }
                    }

                }

            }
            Item {
                id: sepLine1
                height:unitHeight*0.1
                width:unitWidth*4.5
                Rectangle{
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: qgcPal.window
                    width: unitWidth*5
                    height: 1
                }
            }

            Item {
                id: batteryTempItem
                height: unitHeight
                width: parent.height
                Row{
                    id:batteryTempRow
                    height: parent.height
                    width: parent.width
                    Text {
                        id: batteryTempText
                        width:2.7*unitWidth
                        text: qsTr("电池温度")
                        font.pointSize: 10
                        font.family: "华文中宋"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: batteryTempValue
                        width:2.8*unitWidth
                        text: qsTr("28.6"+"℃")
                        font.pointSize: 10
                        font.family: "华文中宋"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

            }
            Item {
                id: sepLine2
                height:unitHeight*0.1
                width:unitWidth*4.5
                Rectangle{
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: qgcPal.window
                    width: unitWidth*5
                    height: 1
                }
            }

            Item {
                id: flightTimeItem
                height: unitHeight
                width: parent.height
                Row{
                    id:flightTimeItemRow
                    height: parent.height
                    width: parent.width
                    Text {
                        id: flightTimeItemText
                        width:2.7*unitWidth
                        text: qsTr("剩余飞行时间")
                        font.pointSize: 10
                        font.family: "华文中宋"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: flightTimeItemValue
                        width:2.8*unitWidth
                        text: qsTr("8min8s")
                        font.pointSize: 10
                        font.family: "华文中宋"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

            }
            Item {
                id: sepLine3
                height:unitHeight*0.1
                width:unitWidth*4.5
                Rectangle{
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: qgcPal.window
                    width: unitWidth*5
                    height: 1
                }
            }

            Item {
                id: chargeItem
                height: unitHeight
                width: parent.height
                Row{
                    id:chargeRow
                    height: parent.height
                    width: parent.width
                    Text {
                        id: chargeText
                        width:2.7*unitWidth
                        text: qsTr("充电状态")
                        font.pointSize: 10
                        font.family: "华文中宋"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: chargeValue
                        width:2.8*unitWidth
                        text: qsTr("未充电")
                        font.pointSize: 10
                        font.family: "华文中宋"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

            }
            Item {
                id: sepLine4
                height:unitHeight*0.1
                width:unitWidth*4.5
                Rectangle{
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: qgcPal.window
                    width: unitWidth*5
                    height: 1
                }
            }

            Item {
                id: cellItem
                height: unitHeight
                width: parent.height
                Row{
                    id:cellRow
                    height: parent.height
                    width: parent.width
                    Text {
                        id: cellText
                        width:2.7*unitWidth
                        text: qsTr("电池数目")
                        font.pointSize: 10
                        font.family: "华文中宋"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: cellValue
                        width:2.8*unitWidth
                        text: qsTr("6S")
                        font.pointSize: 10
                        font.family: "华文中宋"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

            }



        }

    }

   }
}
