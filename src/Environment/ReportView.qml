
import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl                       1.0
import QGroundControl.AutoPilotPlugin       1.0
import QGroundControl.Palette               1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0


Rectangle {
    id:     reportview
    color:  qgcPal.window
    z:      QGroundControl.zOrderTopMost

    property real _margin:          ScreenTools.defaultFontPixelWidth
    property real _butttonWidth:    ScreenTools.defaultFontPixelWidth * 10


            SqlQueryModel{
                id: model1
                Component.onCompleted: {
                    model1.setDatabase("test");
                    model1.setQuery("select * from happytest5");
                    tableview.model = model1;
                }
            }

            TableView {
                id: tableview
                width: parent.width-_butttonWidth
                height: parent.height
                anchors.margins: 10


                TableViewColumn { role: "id" ; title: "ID"; visible: true ;width: 50}
                TableViewColumn { role: "t_time" ; title: "time" }
                TableViewColumn { role: "t_time_time" ; title: "t_time_time" }
                TableViewColumn { role: "longitude" ; title: "longitude" }
                TableViewColumn { role: "latitude" ; title: "latitude" }
                TableViewColumn { role: "altitude" ; title: "altitude" }
                TableViewColumn { role: "tempreture" ; title: "temperture" }
                TableViewColumn { role: "humidity" ; title: "humidity" }
                TableViewColumn { role: "presure" ; title: "presure" }
                TableViewColumn { role: "pm2_5" ; title: "pm2_5" }
                TableViewColumn { role: "pm10" ; title: "pm_10" }
                TableViewColumn { role: "SO2" ; title: "SO2" }
                TableViewColumn { role: "NO2" ; title: "NO2" }
                TableViewColumn { role: "CO" ; title: "CO" }
                TableViewColumn { role: "O3" ; title: "O3" }

            }


            Column {
                spacing:            _margin
                width: _butttonWidth
                anchors.left: tableview.right
                Layout.alignment:   Qt.AlignTop | Qt.AlignLeft

                QGCButton {

                    text:       qsTr("Refresh")
                    width:      _butttonWidth

                    onClicked: {

                    }
                }

                QGCButton {

                    text:       qsTr("Download")
                    width:      _butttonWidth
                    onClicked: {

                    }

                }

                QGCButton {
                    text:       qsTr("Erase All")
                    width:      _butttonWidth

                }

                QGCButton {
                    text:       qsTr("Cancel")
                    width:      _butttonWidth
                }
            } // Column - Buttons

}
