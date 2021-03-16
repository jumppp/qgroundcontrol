﻿import QtQuick          2.3
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
        anchors.fill:parent
        clip: true


        Grid{
            id:chargrid
            columns:1
            spacing:0



            ChartView{
                id:                     pm25_pm10chart
                width:                  800
                height:                 600
                visible:                true
                ValueAxis{
                    id:             pm25_pm10x_axis
                    min:            30
                    max:            50
                    tickCount:      10
                }
                ValueAxis{
                    id:             pm25_pm10_y_axis
                    min:            35
                    max:            70
                    tickCount:      10
                }

                ScatterSeries{
                    id:             pm25_pm10line
                    axisX:          pm25_pm10x_axis
                    axisY:          pm25_pm10_y_axis
                    name:           "pm2.5/pm10(ug/cm3)"
                }
            }

            ChartView{
                id:                     pm25_tempchart
                width:                  800
                height:                 600
                visible:                true

                ValueAxis{
                    id:             pm25_temp_x_axis
                    min:            0
                    max:            200
                    tickCount:      10
                }
                ValueAxis{
                    id:             pm25_temp_y_axis
                    min:            0
                    max:            200
                    tickCount:      10
                }

                ScatterSeries{
                    id:             pm25_templine
                    axisX:          pm25_temp_x_axis
                    axisY:          pm25_temp_y_axis
                    name:           "pm10(ug/cm3)"
                }
            }


        }
    }
    //用于获取xy轴数据

    Component.onCompleted: {



        getValue(databasePm25,databasePm10,pm25_pm10line,pm25_pm10x_axis,pm25_pm10_y_axis,pm25name,pm10name)
        getXYValue(databasePm25,databaseTempreture,pm25_templine,pm25_temp_x_axis)

    }

}
