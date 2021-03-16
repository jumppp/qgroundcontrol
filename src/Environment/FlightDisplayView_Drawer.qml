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

    property var aircolor: ["#008000","#FFFF00","#FFA500","#FF0000","#800080","#A52A2A"];

    function iAQI_PM25_cal(x){
        var a=[]
        if(x>=0 && x<35){
            a[0]=((50-0)/(35-0))*(x-0)+0;
            a[1]=aircolor[0];
            return a;
        }
        else if(x>=35&&x<75){
            a[0]=((100-50)/(75-35))*(x-35)+50;
            a[1]=aircolor[1];
            return a;
        }
        else if(x>=75&&x<115){
            a[0]=((150-100)/(115-75))*(x-75)+100;
            a[1]=aircolor[2];
            return a;
        }
        else if(x>=115&&x<150){
            a[0]=((200-150)/(150-115))*(x-115)+150;
            a[1]=aircolor[3];
            return a;
        }
        else if(x>=150&&x<250){
            a[0]=((300-200)/(250-150))*(x-150)+200;
            a[1]=aircolor[4];
            return a;
        }
        else if(x>=250&&x<350){
            a[0]=((400-300)/(350-250))*(x-250)+300;
            a[1]=aircolor[5];
            return a;
        }
        else if(x>=350){
            a[0]=((500-400)/(500-350))*(x-350)+400;
            a[1]=aircolor[5];
            return a;
        }
        else return "Error";
    }

    function iAQI_PM10_cal(x){
    var a=[]
    if(x>=0 && x<50){
        a[0]=((50-0)/(50-0))*(x-0)+0;
        a[1]=aircolor[0];
        return a;
    }
    else if(x>=50&&x<150){
        a[0]=((100-50)/(150-50))*(x-50)+50;
        a[1]=aircolor[1];
        return a;
    }
    else if(x>=150&&x<250){
        a[0]=((150-100)/(250-150))*(x-150)+100;
        a[1]=aircolor[2];
        return a;
    }
    else if(x>=250&&x<350){
        a[0]=((200-150)/(350-250))*(x-250)+150;
        a[1]=aircolor[3];
        return a;
    }
    else if(x>=350&&x<420){
        a[0]=((300-200)/(420-350))*(x-350)+200;
        a[1]=aircolor[4];
        return a;
    }
    else if(x>=420&&x<500){
        a[0]=((400-300)/(500-420))*(x-420)+300;
        a[1]=aircolor[5];
        return a;
    }
    else if(x>=500){
        a[0]=((500-400)/(600-500))*(x-500)+400;
        a[1]=aircolor[5];
        return a;
    }
    else return "Error";
}

function iAQI_o3_cal(x){
var a=[]
if(x>=0 && x<160){
    a[0]=((50-0)/(160-0))*(x-0)+0;
    a[1]=aircolor[0];
    return a;
}
else if(x>=160&&x<200){
    a[0]=((100-50)/(200-160))*(x-160)+50;
    a[1]=aircolor[1];
    return a;
}
else if(x>=200&&x<300){
    a[0]=((150-100)/(300-200))*(x-200)+100;
    a[1]=aircolor[2];
    return a;
}
else if(x>=300&&x<400){
    a[0]=((200-150)/(400-300))*(x-300)+150;
    a[1]=aircolor[3];
    return a;
}
else if(x>=400&&x<800){
    a[0]=((300-200)/(800-400))*(x-400)+200;
    a[1]=aircolor[4];
    return a;
}
else if(x>=800&&x<1000){
    a[0]=((400-300)/(1000-800))*(x-800)+300;
    a[1]=aircolor[5];
    return a;
}
else if(x>=1000){
    a[0]=((500-400)/(1200-1000))*(x-1000)+400;
    a[1]=aircolor[5];
    return a;
}
else return "Error";
}

function iAQI_so2_cal(x){
var a=[]
if(x>=0 && x<150){
    a[0]=((50-0)/(150-0))*(x-0)+0;
    a[1]=aircolor[0];
    return a;
}
else if(x>=150&&x<500){
    a[0]=((100-50)/(500-150))*(x-150)+50;
    a[1]=aircolor[1];
    return a;
}
else if(x>=500&&x<650){
    a[0]=((150-100)/(650-500))*(x-500)+100;
    a[1]=aircolor[2];
    return a;
}
else if(x>=650&&x<800){
    a[0]=((200-150)/(800-650))*(x-650)+150;
    a[1]=aircolor[3];
    return a;
}
else if(x>=800&&x<1600){
    a[0]=((300-200)/(1600-800))*(x-800)+200;
    a[1]=aircolor[4];
    return a;
}
else if(x>=1600&&x<2100){
    a[0]=((400-300)/(2100-1600))*(x-1600)+300;
    a[1]=aircolor[5];
    return a;
}
else if(x>=2100){
    a[0]=((500-400)/(2620-2100))*(x-2100)+400;
    a[1]=aircolor[5];
    return a;
}
else return "Error";
}

function iAQI_no2_cal(x){
var a=[]
if(x>=0 && x<100){
    a[0]=((50-0)/(100-0))*(x-0)+0;
    a[1]=aircolor[0];
    return a;
}
else if(x>=100&&x<200){
    a[0]=((100-50)/(200-100))*(x-100)+50;
    a[1]=aircolor[1];
    return a;
}
else if(x>=200&&x<700){
    a[0]=((150-100)/(700-200))*(x-200)+100;
    a[1]=aircolor[2];
    return a;
}
else if(x>=700&&x<1200){
    a[0]=((200-150)/(1200-700))*(x-700)+150;
    a[1]=aircolor[3];
    return a;
}
else if(x>=1200&&x<2340){
    a[0]=((300-200)/(2340-1200))*(x-1200)+200;
    a[1]=aircolor[4];
    return a;
}
else if(x>=2340&&x<3090){
    a[0]=((400-300)/(3090-2340))*(x-2340)+300;
    a[1]=aircolor[5];
    return a;
}
else if(x>=3090){
    a[0]=((500-400)/(3840-3090))*(x-3090)+400;
    a[1]=aircolor[5];
    return a;
}
else return "Error";
}

function iAQI_co_cal(x){
var a=[]
if(x>=0 && x<5){
    a[0]=((50-0)/(5-0))*(x-0)+0;
    a[1]=aircolor[0];
    return a;
}
else if(x>=5&&x<10){
    a[0]=((100-50)/(10-5))*(x-5)+50;
    a[1]=aircolor[1];
    return a;
}
else if(x>=10&&x<35){
    a[0]=((150-100)/(35-10))*(x-10)+100;
    a[1]=aircolor[2];
    return a;
}
else if(x>=35&&x<60){
    a[0]=((200-150)/(60-35))*(x-35)+150;
    a[1]=aircolor[3];
    return a;
}
else if(x>=60&&x<90){
    a[0]=((300-200)/(90-60))*(x-60)+200;
    a[1]=aircolor[4];
    return a;
}
else if(x>=90&&x<120){
    a[0]=((400-300)/(120-90))*(x-90)+300;
    a[1]=aircolor[5];
    return a;
}
else if(x>=120){
    a[0]=((500-400)/(150-120))*(x-120)+400;
    a[1]=aircolor[5];
    return a;
}
else return "Error";
}

function aQi_cal(){
    var aqimax=[]
    var value = [iAQI_PM25_cal(activeVehicle.gasSensor.pm25.value)[0],
                 iAQI_PM10_cal(activeVehicle.gasSensor.pm10.value)[0],
                 iAQI_o3_cal(activeVehicle.gasSensor.o3.value)[0],
                 iAQI_so2_cal(activeVehicle.gasSensor.so2.value/10)[0],
                 iAQI_no2_cal(activeVehicle.gasSensor.no2.value)[0],
                 iAQI_co_cal(activeVehicle.gasSensor.co.value/100)[0]
            ]
    var gasType=["PM2.5","PM10","O3","SO2","NO2","CO"]

    aqimax[1]=Math.round(Math.max.apply(null,value))
    aqimax[0]=gasType[value.indexOf(Math.max.apply(null,value))]
    if(aqimax[1]>=0 && aqimax[1]<50){
        aqimax[2]=aircolor[0];
        aqimax[3]="优"
    }
    else if(aqimax[1]>=50&&aqimax[1]<100){
         aqimax[2]=aircolor[1];
         aqimax[3]="良"
    }
    else if(aqimax[1]>=100&&aqimax[1]<150){
         aqimax[2]=aircolor[2];
         aqimax[3]="轻度污染"
    }
    else if(aqimax[1]>=150&&aqimax[1]<200){
         aqimax[2]=aircolor[3];
         aqimax[3]="中度污染"
    }
    else if(aqimax[1]>=200&&aqimax[1]<300){
         aqimax[2]=aircolor[4];
         aqimax[3]="重度污染"
    }
    else {
         aqimax[2]=aircolor[5];
         aqimax[3]="严重污染"
    }

    return aqimax

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
                    text:_activeVehicle?aQi_cal()[3]:"无"
                    font.family: "华文中宋"
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 18
                    color: _activeVehicle?aQi_cal()[2]:"white"
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
                    text: _activeVehicle?aQi_cal()[1]:"10"
                    font.family: "Comic Sans MS"
                    font.pixelSize:  45
                    color: _activeVehicle?aQi_cal()[2]:"white"
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
                text: _activeVehicle?aQi_cal()[0]:"PM10"
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
                text: _activeVehicle?_activeVehicle.gasSensor.gasTemperature.value/100:"25.26"
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
                text: _activeVehicle?_activeVehicle.gasSensor.humidity.value:"66"
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
                text: _activeVehicle?_activeVehicle.gasSensor.gasPressure.value:"102308"
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
                text: _activeVehicle?_activeVehicle.gps.lat.value.toFixed(6):"120.365767"
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
                text: _activeVehicle?_activeVehicle.gps.lon.value.toFixed(6):"30.321777"
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
                text: _activeVehicle?_activeVehicle.altitudeRelative.value.toFixed(2):"1.20"
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
                    color: _activeVehicle?iAQI_PM25_cal(activeVehicle.gasSensor.pm25.value)[1]:"white"
                }

                Text {
                    id: pm25Value
                    width: unitWidth*1.4
                    height:unitHeight*0.9
                    anchors.left: pm25Rect.right
                    anchors.top:pm25Text.bottom
                    text:_activeVehicle?_activeVehicle.gasSensor.pm25.value:"40"
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
                    color:  _activeVehicle?iAQI_PM10_cal(activeVehicle.gasSensor.pm10.value)[1]:"white"
                }

                Text {
                    id: pm10Value
                    width: unitWidth*1.4
                    height:unitHeight*0.9
                    anchors.left: pm10Rect.right
                    anchors.top:pm10Text.bottom
                    text:_activeVehicle?_activeVehicle.gasSensor.pm10.value:"54"
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
                    color: _activeVehicle?iAQI_o3_cal(activeVehicle.gasSensor.o3.value)[1]:"white"
                }

                Text {
                    id: o3Value
                    width: unitWidth*1.4
                    height:unitHeight*0.9
                    anchors.left: o3Rect.right
                    anchors.top:o3Text.bottom
                    text:_activeVehicle?_activeVehicle.gasSensor.o3.value:"57"
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
                    color: _activeVehicle?iAQI_so2_cal(activeVehicle.gasSensor.so2.value/10)[1]:"white"
                }

                Text {
                    id: so2Value
                    width: unitWidth*1.4
                    height:unitHeight*0.9
                    anchors.left: so2Rect.right
                    anchors.top:so2Text.bottom
                    text:_activeVehicle?Math.round(_activeVehicle.gasSensor.so2.value/10):"6"
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
                    color: _activeVehicle?iAQI_no2_cal(activeVehicle.gasSensor.no2.value)[1]:"white"
                }

                Text {
                    id: no2Value
                    width: unitWidth*1.4
                    height:unitHeight*0.9
                    anchors.left: no2Rect.right
                    anchors.top:no2Text.bottom
                    text:_activeVehicle?_activeVehicle.gasSensor.no2.value:"28"
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
                    color: _activeVehicle?iAQI_co_cal(activeVehicle.gasSensor.co.value/100)[1]:"white"
                }

                Text {
                    id: coValue
                    width: unitWidth*1.4
                    height:unitHeight*0.9
                    anchors.left: coRect.right
                    anchors.top:coText.bottom
                    text:_activeVehicle?_activeVehicle.gasSensor.co.value/100:"0.5"
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
