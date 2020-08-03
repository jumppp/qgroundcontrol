
import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QtCharts         2.2
import QtQuick.Dialogs  1.2
import QGroundControl                       1.0
import QGroundControl.Controllers           1.0
import QGroundControl.AutoPilotPlugin       1.0
import QGroundControl.Palette               1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0


Rectangle {
    id:     reportview
    color:  qgcPal.window
    z:      QGroundControl.zOrderTopMost

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    ExclusiveGroup { id: setupButtonGroup }

    property real _margin:          ScreenTools.defaultFontPixelWidth
    property real _butttonWidth:    ScreenTools.defaultFontPixelWidth * 10
    property var iDent: -1
    property var a: []
    property var aa:[]
    SqlQueryModel{
        id: model1
    }
    Database_Env{
        id:mydatabase
    }



    TableView {
        id: tableview
        anchors.left:parent.left
        anchors.top:parent.top
        anchors.bottom: parent.bottom

        width: parent.width-_butttonWidth-_margin

        TableViewColumn { role: "id" ; title: "ID"; visible: true ;width: 50}
        TableViewColumn { role: "t_time" ; title: "time" ;width: 180}
        TableViewColumn { role: "identification" ; title: "identification" }
        TableViewColumn { role: "longitude" ; title: "longitude";width: 150 }
        TableViewColumn { role: "latitude" ; title: "latitude";width: 150 }
        TableViewColumn { role: "altitude" ; title: "altitude" ;width: 50}
        TableViewColumn { role: "tempreture" ; title: "temperture" ;width: 50}
        TableViewColumn { role: "humidity" ; title: "humidity" ;width: 50}
        TableViewColumn { role: "presure" ; title: "presure" ;width: 80}
        TableViewColumn { role: "pm2_5" ; title: "pm2_5";width: 50}
        TableViewColumn { role: "pm10" ; title: "pm_10" ;width: 50}
        TableViewColumn { role: "SO2" ; title: "SO2" ;width: 50}
        TableViewColumn { role: "NO2" ; title: "NO2" ;width: 50}
        TableViewColumn { role: "CO" ; title: "CO" ;width: 50}
        TableViewColumn { role: "O3" ; title: "O3";width: 50 }


        onClicked: {
            iDent = model1.getIndex(tableview.currentRow,3);
            console.log(iDent)
        }
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
                    model1.setDatabase("test");
                    model1.setQuery("select * from happytest7 group by identification order by identification")
                    tableview.model = model1;
                }
            }

            QGCButton {

                text:       qsTr("Download")
                width:      _butttonWidth
                onClicked: {
                    if(iDent == -1)
                    {
                         console.log("iDent == -1")
                    }
                    else
                    {
                        mydatabase.exportCsv(iDent)
                    }

                }


            }

            QGCButton {
                text:       qsTr("Erase All")
                width:      _butttonWidth
                onClicked: {
                    model1.eraseAll();
                }

            }

            QGCButton {
                text:       qsTr("Cancel")
                width:      _butttonWidth
                onClicked: {
                    //var o=tableview.currentRow

                    //                        for(var i=1;i<10;i++){
                    //                           var q = model1.getIndex(i,9)
                    //                            a.push(q)
                    //                        }
                    //                        //9代表pm25的列

                    aa=[]
                    a=[]
                    tempchart.visible=!tempchart.visible
                    for(var s=1;s<5;s++){
                        var qq = model1.getIndex(s,1)
                        aa.push(qq)
                    }

                    for(var i=1;i<5;i++){
                        var q = model1.getIndex(i,9)
                        a.push(q)
                    }


                    console.log("a:",a,"aa",aa)
                    x_axis.min=aa[0]
                    x_axis.max=aa[3]
                    templine.clear()
                    for(var t=0;t<4;t++){
                        templine.append(aa[t],a[t])
                    }

                }
            }

            QGCButton {

                text:       qsTr("All Data")
                width:      _butttonWidth

                onClicked: {
                    model1.setDatabase("test");
                    model1.setQuery("select * from happytest7");
                    tableview.model = model1;
                }
            }
            QGCButton {

                text:       qsTr("Start Store")
                width:      _butttonWidth

                onClicked: {
                    mydatabase.connect_Database()
                }
            }

            QGCButton {

                text:       qsTr("STOP")
                width:      _butttonWidth

                onClicked: {
                    mydatabase.disconnect_Database()
                }
            }
        } // Column - Buttons


}

