/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Layouts          1.2
import QtQuick.Window           2.2
import QtQml.Models             2.1

import QGroundControl               1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.MultiVehicleManager   1.0

/// Flight Display View
QGCView {
    id:         drawer_View
    QGCPalette { id: qgcPal }
    Database_Env{id:database_env}
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property var drawerWidth: drawer_View.width
    property var drawerHeight: drawer_View.height
    property var unitWidth: drawer_View.width/6
    property var unitHeight: drawer_View.height/14.6
    ExclusiveGroup { id: setupButtonGroup }

    function currentDateTime(){
        return Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss");
    }

    //定时器
    Timer{
        id: timer
        interval: 1000 //间隔(单位毫秒):1000毫秒=1秒
        repeat: true //重复
        onTriggered:{
            textId.text = currentDateTime();
        }
    }
    //timeColumn is used to show time
    Item{
        id:timeColumn
        height: unitHeight*0.8
        width:  drawerWidth
        Rectangle{
            id:timeRecId
            radius:20
            anchors.fill:parent
            color: qgcPal.window
            QGCLabel{
                id: textId
                text: currentDateTime();
                font.pointSize: 12
                color: qgcPal.text
                anchors.centerIn:  parent
            }

            Component.onCompleted: {
                timer.start();
            }
            //以下两个rec用来补圆角
            Rectangle{
                color: qgcPal.window
                height: unitHeight*0.4
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width:  20
            }
            Rectangle{
                color: qgcPal.window
                height: unitHeight*0.4
                width:  20
                anchors.right:parent.right
                anchors.bottom: parent.bottom
            }
        }

    }
    // emptyLeftItem lefr empty area
    Item {
        id: emptyLeftItem
        width: unitWidth*1.2
        height: unitHeight*13.8
        anchors.left: parent.left
        anchors.top: timeColumn.bottom
    }
    // fillColumn fill data
    Column
    {
        id:fillColumn
        anchors.left: emptyLeftItem.right
        anchors.top: timeColumn.bottom
        width: unitWidth*4.8
        height: unitHeight*13.8
        Item {
            id: empty
            height:unitHeight*0.6
            width: drawerWidth*4.8
            MouseArea{
                anchors.fill: parent
                onClicked:{
                    console.log("this is empty")
                }
            }
        }

        Item {
            id:aqiRecId
            height: unitHeight*1.6
            width: drawerWidth*4.8
            Item {
                id: aqiLaeblItem
                width:unitWidth*2.1
                height:unitHeight*0.8
                Text{
                    id:aqiLaebl
                    text: "AQI:"
                    font.family: "黑体"
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 25
                    color: "black"
                }
            }
            Item {
                id: aqiLevelItem
                anchors.top:aqiLaeblItem.bottom
                width:unitWidth*2.1
                height:unitHeight*0.8
                Text {
                    id: aqiLevel
                    text: "重度污染"
                    font.family: "华文中宋"
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 18
                    color: "#E95513"
                }
            }

            Item{
                id:aqiTextItem
                height:unitHeight*1.6
                width:unitWidth*2.7
                anchors.left: aqiLaeblItem.right
                //anchors.top:parent.bottom
                Text {
                    id: aqiText
                    text: qsTr("158")
                    font.family: "Comic Sans MS"
                    font.pixelSize:  45
                    color: aqiLevel.color
                    anchors.centerIn: parent
                }
            }
        }

        Item {
            id: mainpolutionItem
            height:unitHeight
            width:unitWidth*4.8
            Text {
                id: mainpolutionText
                height:unitHeight*0.7
                width:unitWidth*2.1
                text: qsTr("首要污染物:")
                font.family: "华文中宋"
                font.pixelSize: 18
            }
            Text {
                id: mainpolutionTextValue
                anchors.left: mainpolutionText.right
                height:unitHeight
                width:unitWidth*2.7
                text: qsTr("PM2.5")
                font.family: "华文中宋"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 28
            }
        }
        Item {
            id: empty2
            height:unitHeight*0.1
            width: drawerWidth*4.8
        }
        Item {
            id: sepLine1
            height:unitHeight*0.2
            width:unitWidth*4.8
            Text {
                id: weatherText
                text: qsTr("气象信息")
                color: "blue"
                font.pixelSize: 12

            }
            Rectangle{
                anchors.left: weatherText.right
                anchors.verticalCenter: parent.verticalCenter
                color: qgcPal.window
                width: unitWidth*3.5
                height: 1
            }
        }
        Item {
            id: temperatureItem
            height:unitHeight*0.7
            width:unitWidth*4.8
            Text {
                id: temperatureText
                width:unitWidth*2.1
                height: unitHeight*0.7
                text: "温度"
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14
            }
            Text {
                id: temperatureValue
                anchors.left: temperatureText.right
                width:unitWidth*2.7
                height: unitHeight*0.7
                text: "25.85℃"
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }

        }

        Item {
            id: humidityItem
            height:unitHeight*0.7
            width:unitWidth*4.8
            Text {
                id: humidityText
                width:unitWidth*2.1
                height: unitHeight*0.7
                text:qsTr("湿度")
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14
            }
            Text {
                id:humidityValue
                anchors.left: humidityText.right
                width:unitWidth*2.7
                height: unitHeight*0.7
                text: qsTr("56%")
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }

        }
        Item {
            id: gasPressureItem
            height:unitHeight*0.7
            width:unitWidth*4.8
            Text {
                id: gasPressureText
                width:unitWidth*2.1
                height: unitHeight*0.7
                text: "大气压"
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14
            }
            Text {
                id: gasPressureValue
                anchors.left: gasPressureText.right
                width:unitWidth*2.7
                height: unitHeight*0.7
                text: "1.01MPa"
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }

        }
        Item {
            id: sepLine2
            height:unitHeight*0.2
            width:unitWidth*4.8
            Text {
                id: geoText
                text: qsTr("地理信息")
                color: "blue"
                font.pixelSize: 12

            }
            Rectangle{
                anchors.left: geoText.right
                anchors.verticalCenter: parent.verticalCenter
                color: qgcPal.window
                width: unitWidth*3.5
                height: 1
            }
        }
        Item {
            id: lonItem
            height:unitHeight*0.7
            width:unitWidth*4.8
            Text {
                id: lonText
                width:unitWidth*2.1
                height: unitHeight*0.7
                text: "经度"
                verticalAlignment: Text.AlignVCenter
                font.pixelSize:14
            }
            Text {
                id: lonValue
                anchors.left: lonText.right
                width:unitWidth*2.7
                height: unitHeight*0.7
                text: "120.358488"
                font.pixelSize:14
                verticalAlignment: Text.AlignVCenter
            }

        }

        Item {
            id: latItem
            height:unitHeight*0.7
            width:unitWidth*4.8
            Text {
                id: latText
                width:unitWidth*2.1
                height: unitHeight*0.7
                text: "纬度"
                verticalAlignment: Text.AlignVCenter
                font.pixelSize:14
            }
            Text {
                id: latValue
                anchors.left: latText.right
                width:unitWidth*2.7
                height: unitHeight*0.7
                text: "30.353279"
                font.pixelSize:14
                verticalAlignment: Text.AlignVCenter
            }

        }
        Item {
            id: altItem
            height:unitHeight*0.7
            width:unitWidth*4.8
            Text {
                id: altText
                width:unitWidth*2.1
                height: unitHeight*0.7
                text: "高度"
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14
            }
            Text {
                id: altValue
                anchors.left: altText.right
                width:unitWidth*2.7
                height: unitHeight*0.7
                text: "1.36"
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }

        }
        Item {
            id: sepLine3
            height:unitHeight*0.2
            width:unitWidth*4.8
            Text {
                id: gasText
                text: qsTr("常规大气信息")
                color: "blue"
                font.pixelSize:12

            }
            Rectangle{
                anchors.left: gasText.right
                anchors.verticalCenter: parent.verticalCenter
                color: qgcPal.window
                width: unitWidth*3.5
                height: 1
            }
        }

        Item {
            id: emptyLeftItem2
            height:unitHeight*0.2
            width:unitWidth*4.8
        }

        Grid{
            height:unitHeight*5.6
            width:unitWidth*4.8
            columns: 2
            spacing: 3
            Item {
                id: pm25Item
                width:unitWidth*2.3;
                height:unitHeight*1.7
                Item {
                    id: emptyItem1
                    width: unitWidth*0.4
                    height:unitHeight*1.8
                }

                Text {
                    id: pm25Text
                    width: unitWidth*1.9
                    height:unitHeight*0.4
                    anchors.left: emptyItem1.right
                    anchors.top: parent.top
                    text: qsTr("PM2.5:")
                    font.pixelSize: 15
                    font.family: "黑体"
                    color:"white"
                }

                Rectangle{
                    id: pm25Rect
                    anchors.left: emptyItem1.right
                    anchors.top:pm25Text.bottom
                    width: unitWidth*0.3
                    height:unitHeight*1.2
                    color: "green"
                }

                Text {
                    id: pm25Value
                    width: unitWidth*1.4
                    height:unitHeight*0.9
                    anchors.left: pm25Rect.right
                    anchors.top:pm25Text.bottom
                    text:_activeVehicle?_activeVehicle.gasSensor.pm25.value:"0"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 30
                    color: "white"

                }
                Text {
                    id: pm25Unit
                    anchors.left: pm25Rect.right
                    anchors.top: pm25Value.bottom
                    width: unitWidth*1.4
                    height:unitHeight*0.3
                    text: qsTr("(ug/cm3)")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 12
                    color: "white"
                }

            }
            Item {
                id: pm10Item
                width:unitWidth*2.3;
                height:unitHeight*1.7
                Item {
                    id: emptyItem2
                    width: unitWidth*0.4
                    height:unitHeight*1.8
                }

                Text {
                    id: pm10Text
                    width: unitWidth*1.9
                    height:unitHeight*0.4
                    anchors.left: emptyItem2.right
                    anchors.top: parent.top
                    text: qsTr("PM10:")
                    font.pixelSize: 15
                    font.family: "黑体"
                    color:"white"
                }

                Rectangle{
                    id: pm10Rect
                    anchors.left: emptyItem2.right
                    anchors.top:pm10Text.bottom
                    width: unitWidth*0.3
                    height:unitHeight*1.2
                    color: "#FFF000"
                }

                Text {
                    id: pm10Value
                    width: unitWidth*1.4
                    height:unitHeight*0.9
                    anchors.left: pm10Rect.right
                    anchors.top:pm10Text.bottom
                    text:"56"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 30
                    color: "white"

                }
                Text {
                    id: pm10Unit
                    anchors.left: pm10Rect.right
                    anchors.top: pm10Value.bottom
                    width: unitWidth*1.4
                    height:unitHeight*0.3
                    text: qsTr("(ug/cm3)")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize:12
                    color: "white"
                }

            }
            Item {
                id: o3Item
                width:unitWidth*2.3
                height:unitHeight*1.7
                Item {
                    id: emptyItem3
                    width: unitWidth*0.4
                    height:unitHeight*1.8
                }

                Text {
                    id: o3Text
                    width: unitWidth*1.9
                    height:unitHeight*0.4
                    anchors.left: emptyItem3.right
                    anchors.top: parent.top
                    text: qsTr("O3:")
                    font.pixelSize: 15
                    font.family: "黑体"
                    color:"white"
                }

                Rectangle{
                    id: o3Rect
                    anchors.left: emptyItem3.right
                    anchors.top:o3Text.bottom
                    width: unitWidth*0.3
                    height:unitHeight*1.2
                    color: "green"
                }

                Text {
                    id: o3Value
                    width: unitWidth*1.4
                    height:unitHeight*0.9
                    anchors.left: o3Rect.right
                    anchors.top:o3Text.bottom
                    text:"131"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize:30
                    color: "white"

                }
                Text {
                    id: o3Unit
                    anchors.left: o3Rect.right
                    anchors.top: o3Value.bottom
                    width: unitWidth*1.4
                    height:unitHeight*0.3
                    text: qsTr("(ppb)")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize:12
                    color: "white"
                }

            }
            Item {
                id: so2Item
                width:unitWidth*2.3;
                height:unitHeight*1.7
                Item {
                    id: emptyItem4
                    width: unitWidth*0.4
                    height:unitHeight*1.8
                }

                Text {
                    id: so2Text
                    width: unitWidth*1.9
                    height:unitHeight*0.4
                    anchors.left: emptyItem4.right
                    anchors.top: parent.top
                    text: qsTr("SO2:")
                    font.pixelSize: 15
                    font.family: "黑体"
                    color:"white"
                }

                Rectangle{
                    id: so2Rect
                    anchors.left: emptyItem4.right
                    anchors.top:so2Text.bottom
                    width: unitWidth*0.3
                    height:unitHeight*1.2
                    color: "#E95513"
                }

                Text {
                    id: so2Value
                    width: unitWidth*1.4
                    height:unitHeight*0.9
                    anchors.left: so2Rect.right
                    anchors.top:so2Text.bottom
                    text:"131"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize:30
                    color: "white"

                }
                Text {
                    id: so2Unit
                    anchors.left: so2Rect.right
                    anchors.top: so2Value.bottom
                    width: unitWidth*1.4
                    height:unitHeight*0.3
                    text: qsTr("(ppb)")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize:12
                    color: "white"
                }

            }
            Item {
                id: no2Item
                width:unitWidth*2.3;
                height:unitHeight*1.7
                Item {
                    id: emptyItem5
                    width: unitWidth*0.4
                    height:unitHeight*1.8
                }

                Text {
                    id: no2Text
                    width: unitWidth*1.9
                    height:unitHeight*0.4
                    anchors.left: emptyItem5.right
                    anchors.top: parent.top
                    text: qsTr("NO2:")
                    font.pixelSize:15
                    font.family: "黑体"
                    color:"white"
                }

                Rectangle{
                    id: no2Rect
                    anchors.left: emptyItem5.right
                    anchors.top:no2Text.bottom
                    width: unitWidth*0.3
                    height:unitHeight*1.2
                    color: "#5F1985"
                }

                Text {
                    id: no2Value
                    width: unitWidth*1.4
                    height:unitHeight*0.9
                    anchors.left: no2Rect.right
                    anchors.top:no2Text.bottom
                    text:"275"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize:30
                    color: "white"

                }
                Text {
                    id: no2Unit
                    anchors.left: no2Rect.right
                    anchors.top: no2Value.bottom
                    width: unitWidth*1.4
                    height:unitHeight*0.3
                    text: qsTr("(ppb)")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize:12
                    color: "white"
                }

            }
            Item {
                id: coItem
                width:unitWidth*2.3;
                height:unitHeight*1.8
                Item {
                    id: emptyItem6
                    width: unitWidth*0.4
                    height:unitHeight*1.7
                }

                Text {
                    id: coText
                    width: unitWidth*1.9
                    height:unitHeight*0.4
                    anchors.left: emptyItem6.right
                    anchors.top: parent.top
                    text: qsTr("CO:")
                    font.pixelSize:15
                    font.family: "黑体"
                    color:"white"
                }

                Rectangle{
                    id: coRect
                    anchors.left: emptyItem6.right
                    anchors.top:coText.bottom
                    width: unitWidth*0.3
                    height:unitHeight*1.2
                    color: "green"
                }

                Text {
                    id: coValue
                    width: unitWidth*1.4
                    height:unitHeight*0.9
                    anchors.left: coRect.right
                    anchors.top:coText.bottom
                    text:"5.36"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize:30
                    color: "white"

                }
                Text {
                    id: coUnit
                    anchors.left: coRect.right
                    anchors.top: coValue.bottom
                    width: unitWidth*1.4
                    height:unitHeight*0.3
                    text: qsTr("(ppm)")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize:12
                    color: "white"
                }

            }



        }


    }


}
