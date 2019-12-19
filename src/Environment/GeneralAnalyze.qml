import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QtCharts         2.2
import QtQuick.Window   2.0
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

QGCView{

    id:     generalview
    color:  qgcPal.window
    z:      QGroundControl.zOrderTopMost-1

    QGCPalette { id: qgcPal; colorGroupEnabled: true }
    ExclusiveGroup { id: setupButtonGroup }

    ScrollView{
        id:charscroll
        anchors.fill:   parent


        Grid{
            id:chargrid
            columns:2
            spacing: 5



            ChartView{
                id:                     pm25chart
                width:                  800
                height:                 600
                visible:                true
                DateTimeAxis{
                    id:             pm25_x_axis
                    min:            Date.fromLocaleString(Qt.locale(), "1925-06-08 20:22:26", "hh:mm:ss")
                    max:            Date.fromLocaleString(Qt.locale(), "1925-06-08 20:22:26", "hh:mm:ss")
                    format:         "hh:mm:ss"
                    tickCount:      13
                    titleText:      "时间"
                }
                ValueAxis{
                    id:             pm25_y_axis
                    min:            0
                    max:            200
                    tickCount:      10
                }

                LineSeries{
                    id:             pm25line
                    axisX:          pm25_x_axis
                    axisY:          pm25_y_axis
                    width:          2
                    capStyle:       Qt.FlatCap
                    name:           "pm2.5(ug/cm3)"
                }
            }
            ChartView{
                id:                     pm10chart
                width:                  800
                height:                 600
                visible:                true

                ValueAxis{
                    id:             pm10_y_axis
                    min:            0
                    max:            200
                    tickCount:      10
                }
                DateTimeAxis{
                    id:             pm10_x_axis
                    min:            Date.fromLocaleString(Qt.locale(), "1925-06-08 20:22:26", "hh:mm:ss")
                    max:            Date.fromLocaleString(Qt.locale(), "1925-06-08 20:22:26", "hh:mm:ss")
                    format:         "hh:mm:ss"
                    tickCount:      13
                    titleText:      "时间"
                }
                LineSeries{
                    id:             pm10line
                    axisX:          pm10_x_axis
                    axisY:          pm10_y_axis
                    width:          1
                    capStyle:       Qt.FlatCap
                    name:           "pm10(ug/cm3)"
                }
            }

            ChartView{
                id:                     so2chart
                width:                  800
                height:                 600
                visible:                true

                ValueAxis{
                    id:             so2_y_axis
                    min:            0
                    max:            200
                    tickCount:      10
                }
                DateTimeAxis{
                    id:             so2_x_axis
                    min:            Date.fromLocaleString(Qt.locale(), "1925-06-08 20:22:26", "hh:mm:ss")
                    max:            Date.fromLocaleString(Qt.locale(), "1925-06-08 20:22:26", "hh:mm:ss")
                    format:         "hh:mm:ss"
                    tickCount:      13
                    titleText:      "时间"
                }
                LineSeries{
                    id:             so2line
                    axisX:          so2_x_axis
                    axisY:          so2_y_axis
                    width:          1
                    capStyle:       Qt.FlatCap
                    name:           "ppb"
                }
            }
            QGCButton{
                id:qwe
                text:"asd"
                onClicked:{
                getXYValue(databaseTime,databasePm25,pm25line,pm25_x_axis)
                }

            }
        }
    }
    //用于获取xy轴数据

    Component.onCompleted: {



        //getXYValue(databaseTime,databasePm25,pm25line,pm25_x_axis)
        getXYValue(databaseTime,databasePm10,pm10line,pm10_x_axis)
        getXYValue(databaseTime,databaseSO2,so2line,so2_x_axis)
    }

}
