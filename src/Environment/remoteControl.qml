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
        text: qsTr("遥控器信息")
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
                height: 0.6*unitHeight
                width: parent.width
                Text {
                    id: name
                    text: qsTr("遥控器各通道信息")
                    anchors.verticalCenter: parent.verticalCenter
                }

            }
            Item {
                id: ch1Item
                height: unitHeight*0.8
                width: parent.height
                Row{
                    id:ch1Row
                    height: parent.height
                    width: parent.width
                    Text {
                        id: ch1Text
                        width:1.2*unitWidth
                        text: qsTr("CH1")
                        font.pointSize: 10
                        font.family: "华文中宋"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ProgressBar {
                        id: ch1bar
                        width:3.6*unitWidth
                        property color color: "#3498DB"
                        anchors.verticalCenter: parent.verticalCenter
                        value: 1500
                        from:0
                        to:3000
                        background: Rectangle {
                            implicitWidth: 200
                            implicitHeight: 12
                            color: "#EBEDEF"
                        }

                        contentItem: Item {
                            implicitWidth: ch1bar.background.implicitWidth
                            implicitHeight: ch1bar.background.implicitHeight

                            Rectangle {
                                width: ch1bar.visualPosition * parent.width
                                height: parent.height
                                color: ch1bar.color
                            }
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
                id: ch2Item
                height: unitHeight*0.8
                width: parent.height
                Row{
                    id:ch2Row
                    height: parent.height
                    width: parent.width
                    Text {
                        id: ch2Text
                        width:1.2*unitWidth
                        text: qsTr("CH2")
                        font.pointSize: 10
                        font.family: "华文中宋"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ProgressBar {
                        id: ch2bar
                        width:3.6*unitWidth
                        property color color: "#727CF5"
                        anchors.verticalCenter: parent.verticalCenter
                        value: 1800
                        from:0
                        to:3000
                        background: Rectangle {
                            implicitWidth: 200
                            implicitHeight: 12
                            color: "#EBEDEF"
                        }

                        contentItem: Item {
                            implicitWidth: ch2bar.background.implicitWidth
                            implicitHeight: ch2bar.background.implicitHeight

                            Rectangle {
                                width: ch2bar.visualPosition * parent.width
                                height: parent.height
                                color: ch2bar.color
                            }
                        }
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
                id: ch3Item
                height: unitHeight*0.8
                width: parent.height
                Row{
                    id:chargeRow
                    height: parent.height
                    width: parent.width
                    Text {
                        id: ch3Text
                        width:1.2*unitWidth
                        text: qsTr("CH3")
                        font.pointSize: 10
                        font.family: "华文中宋"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ProgressBar {
                        id: ch3bar
                        width:3.6*unitWidth
                        property color color: "#0ACF97"
                        anchors.verticalCenter: parent.verticalCenter
                        value: 500
                        from:0
                        to:3000
                        background: Rectangle {
                            implicitWidth: 200
                            implicitHeight: 12
                            color: "#EBEDEF"
                        }

                        contentItem: Item {
                            implicitWidth: ch3bar.background.implicitWidth
                            implicitHeight: ch3bar.background.implicitHeight

                            Rectangle {
                                width: ch3bar.visualPosition * parent.width
                                height: parent.height
                                color: ch3bar.color
                            }
                        }
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
                id: ch4TimeItem
                height: unitHeight*0.8
                width: parent.height
                Row{
                    id:ch4Row
                    height: parent.height
                    width: parent.width
                    Text {
                        id: ch4Text
                        width:1.2*unitWidth
                        text: qsTr("CH4")
                        font.pointSize: 10
                        font.family: "华文中宋"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ProgressBar {
                        id: ch4bar
                        width:3.6*unitWidth
                        property color color: "#FFBC00"
                        anchors.verticalCenter: parent.verticalCenter
                        value: 2100
                        from:0
                        to:3000
                        background: Rectangle {
                            implicitWidth: 200
                            implicitHeight: 12
                            color: "#EBEDEF"
                        }

                        contentItem: Item {
                            implicitWidth: ch4bar.background.implicitWidth
                            implicitHeight: ch4bar.background.implicitHeight

                            Rectangle {
                                width: ch4bar.visualPosition * parent.width
                                height: parent.height
                                color: ch4bar.color
                            }
                        }
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
                id: ch5Item
                height: unitHeight*0.8
                width: parent.height
                Row{
                    id:ch5Row
                    height: parent.height
                    width: parent.width
                    Text {
                        id: ch5Text
                        width:1.2*unitWidth
                        text: qsTr("CH5")
                        font.pointSize: 10
                        font.family: "华文中宋"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ProgressBar {
                        id: ch5bar
                        width:3.6*unitWidth
                        property color color: "#F9375E"
                        anchors.verticalCenter: parent.verticalCenter
                        value: 2000
                        from:0
                        to:3000
                        background: Rectangle {
                            implicitWidth: 200
                            implicitHeight: 12
                            color: "#EBEDEF"
                        }

                        contentItem: Item {
                            implicitWidth: ch5bar.background.implicitWidth
                            implicitHeight: ch5bar.background.implicitHeight

                            Rectangle {
                                width: ch5bar.visualPosition * parent.width
                                height: parent.height
                                color: ch5bar.color
                            }
                        }
                    }

                }

            }

            Item {
                id: sepLine5
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
                id: ch6Item
                height: unitHeight*0.8
                width: parent.height
                Row{
                    id:ch6Row
                    height: parent.height
                    width: parent.width
                    Text {
                        id: ch6Text
                        width:1.2*unitWidth
                        text: qsTr("CH6")
                        font.pointSize: 10
                        font.family: "华文中宋"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ProgressBar {
                        id: ch6bar
                        width:3.6*unitWidth
                        property color color: "#212730"
                        anchors.verticalCenter: parent.verticalCenter
                        value: 1000
                        from:0
                        to:3000
                        background: Rectangle {
                            implicitWidth: 200
                            implicitHeight: 12
                            color: "#EBEDEF"
                        }

                        contentItem: Item {
                            implicitWidth: ch6bar.background.implicitWidth
                            implicitHeight: ch6bar.background.implicitHeight

                            Rectangle {
                                width: ch6bar.visualPosition * parent.width
                                height: parent.height
                                color: ch6bar.color
                            }
                        }
                    }

                }

            }


        }

    }

   }
}
