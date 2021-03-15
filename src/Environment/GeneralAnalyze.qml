import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QtCharts         2.2
import QtQuick.Window   2.0
import QtDataVisualization 1.2
import QGroundControl                       1.0
import QGroundControl.Controllers           1.0
import QGroundControl.AutoPilotPlugin       1.0
import QGroundControl.Palette               1.0

import QtQuick.Controls 2.3
import QtQml            2.2
import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.FactControls 1.0
import QGroundControl.FactSystem    1.0

Rectangle{

    id:     generalview
    color:  qgcPal.windowShade
    z:      QGroundControl.zOrderTopMost-1
    QGCPalette { id: qgcPal; colorGroupEnabled: true }
    ExclusiveGroup { id: setupButtonGroup }
    SqlQueryModel{
        id: model1
    }
    Item {
        id: topitem
        width: parent.width
        height: parent.height/8
        anchors.top: parent.top
        anchors.left: parent.left
        Column {
            id:             headingColumn
            width:          parent.width
            spacing:        _margin
            Rectangle{
                height:parent.height/7
                width: parent.width
                color: qgcPal.windowShade
            }

            QGCLabel {
                id:             pageNameLabel
                font.pointSize: 20
                text:qsTr("PM2.5")
                font.family: "黑体"
                color: "white"

            }

            QGCLabel {
                id:             pageDescriptionLabel
                anchors.left:   parent.left
                anchors.right:  parent.right
                wrapMode:       Text.WordWrap
                text: "飞行时间:2021年1月18日 16：40"

            }
        }
    }
    Item {
        id: miditem
        width: parent.width
        height: parent.height/6
        anchors.top: topitem.bottom
        anchors.left: parent.left

        Row{



            Rectangle{
                width: miditem.width/4
                height: miditem.height
                color:"#A9A9A9"
                Text {
                    anchors.centerIn: parent
                    id: name1
                    text: qsTr("AQI:  63")
                    font.pixelSize: 25
                    font.family: "华文中宋"
                    color: "black"
                }
            }
            Rectangle{
                width: miditem.width/4
                height: miditem.height
                color:"#A9A9A9"
                Text {
                    anchors.centerIn: parent
                    id: name2
                    text: qsTr("首要污染物:PM2.5")
                    font.pixelSize: 25
                    font.family: "华文中宋"
                    color: "black"
                }
            }
            Rectangle{
                width: miditem.width/4
                height: miditem.height
                color:"#A9A9A9"
                Text {
                    anchors.centerIn: parent
                    id: name3
                    text: qsTr("空气质量：良")
                    font.pixelSize:25
                    font.family: "华文中宋"
                    color: "black"
                }
            }
            Rectangle{
                width: miditem.width/4
                height: miditem.height
                color:"#A9A9A9"
                Column{
                    Text {
                        height: miditem.height/2
                        id: name4
                        text: qsTr("经度：120.365427")
                        font.pixelSize: 20
                        font.family: "华文中宋"
                        color: "black"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {

                        height: miditem.height/2
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        id: name5
                        text: qsTr("纬度：30.321029")
                        font.pixelSize: 20
                        font.family: "华文中宋"
                        color: "black"
                    }

                }

            }

        }

    }
    Item {
        id: bottomitem
        width: parent.width/2
        height: parent.height*0.66
        anchors.top: miditem.bottom
        anchors.left: parent.left
        anchors.topMargin: 15
        anchors.leftMargin: 5
        Grid{
            columns: 3
            rows:3
            spacing: 5
            Rectangle{
                id:rec1
                color: "#707070"
                width: bottomitem.width/3
                height:bottomitem.height/3
                Column{
                    width: bottomitem.width/3
                    height:bottomitem.height/3
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name6
                            text: qsTr("AQI")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent

                        }
                    }
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name7
                            text: qsTr("63")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }

                    }

                }
            }
            Rectangle{
                id:rec2
                color: "#707070"
                width: bottomitem.width/3
                height:bottomitem.height/3
                Column{
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name21
                            text: qsTr("平均值ug/m3")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }
                    }
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name22
                            text: qsTr("46")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }
                    }

                }
            }
            Rectangle{
                id:rec3
                color: "#707070"
                width: bottomitem.width/3
                height:bottomitem.height/3
                Column{
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name31
                            text: qsTr("监测点个数")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }
                    }
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name32
                            text: qsTr("20")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }

                    }

                }
            }
            Rectangle{
                id:rec4
                color: "#A9A9A9"
                width: bottomitem.width/3
                height:bottomitem.height/3
                Column{
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name41
                            text: qsTr("最小值ug/m3")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }
                    }
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name42
                            text: qsTr("35")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }

                    }

                }
            }
            Rectangle{
                id:rec5
                color: "#A9A9A9"
                width: bottomitem.width/3
                height:bottomitem.height/3
                Column{
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name51
                            text: qsTr("经度：120.365788")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }
                    }
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name52
                            text: qsTr("纬度：30.321166")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }

                    }

                }
            }
            Rectangle{
                id:rec6
                color: "#A9A9A9"
                width: bottomitem.width/3
                height:bottomitem.height/3
                Column{
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name61
                            text: qsTr("高度m")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }
                    }
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name62
                            text: qsTr("13.4")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }

                    }

                }
            }
            Rectangle{
                id:rec7
                color: "#707070"
                width: bottomitem.width/3
                height:bottomitem.height/3
                Column{
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name71
                            text: qsTr("最大值ug/m3")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }
                    }
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name72
                            text: qsTr("56")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }

                    }

                }
            }
            Rectangle{
                id:rec8
                color: "#707070"
                width: bottomitem.width/3
                height:bottomitem.height/3
                Column{
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name81
                            text: qsTr("经度：120.366341")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }
                    }
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name82
                            text: qsTr("纬度：30.322157")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }

                    }

                }
            }
            Rectangle{
                id:rec9
                color: "#707070"
                width: bottomitem.width/3
                height:bottomitem.height/3
                Column{
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name91
                            text: qsTr("高度m")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }
                    }
                    Item{
                        width: bottomitem.width/3
                        height:bottomitem.height/6
                        Text {
                            id: name92
                            text: qsTr("25.1")
                            font.pixelSize: 20
                            font.family: "华文中宋"
                            color: "black"
                            anchors.centerIn: parent
                        }

                    }

                }
            }



        }
    }
    Item{
        id:bottomrightitem
        width: parent.width/2-10
        height: parent.height-miditem.height-topitem.height
        anchors.top: miditem.bottom
        anchors.right: parent.right
        anchors.topMargin: 5

        ChartView{
            id:                     pm25chart
            anchors.fill: parent
            visible:      true
            title: "PM2.5浓度变化"
            ValueAxis{
                id:             xzhou
                min:            0
                max:            20
                tickCount:      10

            }
            ValueAxis{
                id:yzhou

                min:            0
                max:            60
                tickCount:      10
            }
            LineSeries {
                    name: "pm2.5"
                    axisX: xzhou
                    axisY:yzhou
                    XYPoint { x: 0; y: 38 }
                    XYPoint { x: 1; y: 37 }
                    XYPoint { x: 2; y: 43 }
                    XYPoint { x: 3; y: 38 }
                    XYPoint { x: 4; y: 50 }
                    XYPoint { x: 5; y: 38 }
                    XYPoint { x: 6; y: 42 }
                    XYPoint { x: 7; y: 51 }
                    XYPoint { x: 8; y: 56 }
                    XYPoint { x: 9; y: 49}
                    XYPoint { x: 10; y: 43 }
                    XYPoint { x: 11; y: 40 }
                    XYPoint { x: 12; y: 35 }
                    XYPoint { x: 13; y: 36 }
                    XYPoint { x: 14; y: 48 }
                    XYPoint { x: 15; y: 50 }
                    XYPoint { x: 16; y: 50 }
                    XYPoint { x: 17; y: 51 }
                    XYPoint { x: 18; y: 50}
                    XYPoint { x: 19; y: 48 }
                    XYPoint { x: 20; y: 46 }
                }

        }


    }


    //用于获取xy轴数据

    Component.onCompleted: {
        //getXYValue(databaseTime,databasePm25,pm25line,pm25_x_axis)
        //getXYValue(databaseTime,databasePm10,pm10line,pm10_x_axis)
        //getXYValue(databaseTime,databaseSO2,so2line,so2_x_axis)
//        model1.setDatabase("test");
//        var a = model1.setQuery("select * from happytest7 order by longitude")
//        console.log(model1.data())
    }

}
