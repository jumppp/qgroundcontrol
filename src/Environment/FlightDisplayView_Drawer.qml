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

/// Flight Display View
QGCView {
    id:         drawer_View
    QGCPalette { id: qgcPal }
    property var drawerWidth: drawer_View.width
    property var drawerHeight: drawer_View.height
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

    Column{
        anchors.fill: parent
        Rectangle{
            id:timeRecId
            height: drawerHeight/20
            width:  drawerWidth
            radius:20
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
            height: drawerHeight/40
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width:  20
            }
            Rectangle{
                color: qgcPal.window
                height: drawerHeight/40
                width:  20
                anchors.right:parent.right
                anchors.bottom: parent.bottom
            }
        }

        Item {
            id: empty
            height: drawerHeight/20*0.5
        }
        Item {
            id:aqiRecId
            height: drawerHeight/20*2.5
            width:  drawerWidth
            Item {
                id: aqiLaeblItem
                width:drawerWidth*0.4
                height: drawerHeight/20*1.5
                anchors.left: parent.left
                anchors.leftMargin: drawerWidth/6
                Text{
                    id:aqiLaebl
                    text: "AQI"
                    font.family: "Times New Roman"
                    anchors.centerIn: parent
                    font.pixelSize: 35
                    color: "black"
                }
            }
            Item {
                id: aqiLevelItem
                anchors.top:aqiLaeblItem.bottom
                anchors.left: parent.left
                anchors.leftMargin: drawerWidth/6
                width:drawerWidth*0.4
                height: drawerHeight/20
                Text {
                    id: aqiLevel
                    text:"重度污染"
                    font.family: "Trebuchet MS"
                    font.pixelSize: 20
                    anchors.centerIn: parent
                    color: "#E95513"
                }
            }

            Item{
                id:aqiTextItem
                 height: drawerHeight/20*3
                 width: drawerWidth*0.4
                 anchors.left: aqiLaeblItem.right
                 anchors.top:parent.top
            Text {
                id: aqiText
                text: qsTr("158")
                font.family: "Comic Sans MS"
                font.pixelSize: 51
                color: aqiLevel.color
                anchors.centerIn: parent
            }
             }
        }

    }






}
