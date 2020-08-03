
import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QtQuick.Dialogs  1.2
import QtQuick.Window   2.0
import QGroundControl                       1.0
import QGroundControl.Controllers           1.0
import QGroundControl.AutoPilotPlugin       1.0
import QGroundControl.Palette               1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0

Rectangle{
    id:     evaluationview
    color:  qgcPal.window
    z:      QGroundControl.zOrderTopMost

    QGCPalette { id: qgcPal; colorGroupEnabled: true }
    ExclusiveGroup { id: setupButtonGroup }
    SqlQueryModel{id:mymodel}

    property real _margin:          ScreenTools.defaultFontPixelWidth
    property real _butttonWidth:    ScreenTools.defaultFontPixelWidth * 10
    property real databaseTime:             1
    property real databaseIdentification:   3
    property real databaseLongitude:        4
    property real databaseLatitude:         5
    property real databaseAltitude:         6
    property real databaseTempreture:       7
    property real databaseHumidity:         8
    property real databasePressure:         9
    property real databasePm25:             10
    property real databasePm10:             11
    property real databaseSO2:              12
    property real databaseNO2:              13
    property real databaseCO:               14
    property real databaseO3:               15


    readonly property real  _defaultTextHeight:     ScreenTools.defaultFontPixelHeight
    property var currentRow:    -1
    property var identification: 0
    property var xxx: []
    property var yyy:[]
    Item {
        id: toprowitem
        width: parent.width
        height:  parent.height/10
        Row{
            id:toprow
            spacing:            _margin
            anchors.verticalCenter: parent.verticalCenter
            //anchors.horizontalCenter: parent.horizontalCenter
            QGCLabel{
                text:"当前选择是:"
            }
            QGCTextField {
                readOnly:           true
                Layout.fillWidth:   true
                text:               identification

            }

            QGCButton {
                text:       qsTr("Choose")
                width:      _butttonWidth
                onClicked:{
                    mymodel.setDatabase("test")
                    mymodel.setQuery("select * from happytest7 group by identification order by identification desc")
                    tableview.model=mymodel;
                    choseDialog.open()
                }

            }
            QGCButton {
                text:       qsTr("Analyze")
                width:      _butttonWidth
                enabled:    identification!=0
                onClicked: {
                    mymodel.eraseAll()
                    mymodel.setDatabase("test")
                    mymodel.setQuery(String("select * from happytest7 where identification = %1").arg(identification))
                    chartload.source="GeneralAnalyze.qml"

                    //getXYValue(databaseTime,databasePm25,pm25line,pm25_x_axis)


                }
            }

            QGCButton {

                text:       qsTr("All Data")
                width:      _butttonWidth

            }

        }

    }



    Dialog{
        id: choseDialog
        title: "选择飞行场次"
        TableView {
            id: tableview
            anchors.margins: 10
            anchors.fill: parent

            TableViewColumn { role: "id" ; title: "id"; visible: true ;width: 50}
            TableViewColumn { role: "identification" ; title: "identification" ;width: 180}
            TableViewColumn { role: "t_time" ; title: "time" ;width: 180}
        }

        standardButtons: StandardButton.Cancel | StandardButton.Ok
        onAccepted: {

            currentRow=tableview.currentRow
            if(currentRow>-1){
                identification= mymodel.getIndex(currentRow,databaseIdentification)
                if(chartload.source!="ChartTab.qml")
                {
                     console.log("current identification is",identification)
                }

            }

        }
        onRejected: {
            currentRow=-1
            identification=0
        }

    }

    Row {
        id:         buttonRow
        anchors.top:    toprowitem.bottom
        anchors.left: parent.left
        spacing:    _defaultTextHeight / 2
        height:  30

        Repeater {

            id: buttonRepeater

            model: ListModel {
                ListElement {
                    buttonImage:        "/qmlimages/LogDownloadIcon"
                    buttonText:         qsTr("基本监测信息")
                    pageSource:         "GeneralAnalyze.qml"
                }
                ListElement {
                    buttonImage:        "/qmlimages/GeoTagIcon"
                    buttonText:         qsTr("相关性分析")
                    pageSource:         "Correlation.qml"
                }
                ListElement {
                    buttonImage:        "/qmlimages/MavlinkConsoleIcon"
                    buttonText:         qsTr("垂向分析")
                    pageSource:         "Vertical.qml"
                }
            }

            Component.onCompleted: itemAt(0).checked = true

            SubMenuButton {
                imageResource:      buttonImage
                setupIndicator:     false
                exclusiveGroup:     setupButtonGroup
                text:               buttonText
                onClicked:{
                    if(identification==0)
                    {
                        chartload.source="ChartTab.qml"

                    }
                    else
                        {
                           chartload.source = pageSource
                    }
                }

            }
        }
    }


    Loader{
        id:chartload
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom:parent.bottom
        anchors.top:buttonRow.bottom
        source: "ChartTab.qml"
    }


    function getXYValue(xvalue,yvalue,linename,xname)
    {
        //获取record数目
        var o=mymodel.getLastQuery(identification);
        console.log("o is---- ",o)
        //xy轴
        xxx=[]
        yyy=[]

        for(var s=0;s<o;s++){
            var xx = mymodel.getIndex(s,xvalue)
            xxx.push(xx)
        }

        for(var i=0;i<o;i++){
            var yy = mymodel.getIndex(i,yvalue)
            yyy.push(yy)
        }


        console.log("a:",x,"aa",y)
        xname.min=xxx[0]
        xname.max=xxx[o-1]
        linename.clear()
        for(var t=0;t<o;t++){
            linename.append(xxx[t],yyy[t])
        }

    }

}



