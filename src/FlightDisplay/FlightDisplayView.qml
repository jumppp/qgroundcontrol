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
    id:             root
    viewPanel:      _panel

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
    Database_Env {id:mysqlDatabase}
    property alias  guidedController:   guidedActionsController

    property bool activeVehicleJoystickEnabled: _activeVehicle ? _activeVehicle.joystickEnabled : false

    property var    _planMasterController:  masterController
    property var    _missionController:     _planMasterController.missionController
    property var    _geoFenceController:    _planMasterController.geoFenceController
    property var    _rallyPointController:  _planMasterController.rallyPointController
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property bool   _mainIsMap:             QGroundControl.videoManager.hasVideo ? QGroundControl.loadBoolGlobalSetting(_mainIsMapKey,  true) : true
    property bool   _isPipVisible:          QGroundControl.videoManager.hasVideo ? QGroundControl.loadBoolGlobalSetting(_PIPVisibleKey, true) : false
    property bool   _useChecklist:          QGroundControl.settingsManager.appSettings.useChecklist.rawValue
    property real   _savedZoomLevel:        0
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property real   _pipSize:               flightView.width * 0.2
    property alias  _guidedController:      guidedActionsController
    property alias  _altitudeSlider:        altitudeSlider

    readonly property var       _dynamicCameras:        _activeVehicle ? _activeVehicle.dynamicCameras : null
    readonly property bool      _isCamera:              _dynamicCameras ? _dynamicCameras.cameras.count > 0 : false
    readonly property bool      isBackgroundDark:       _mainIsMap ? (_flightMap ? _flightMap.isSatelliteMap : true) : true
    readonly property real      _defaultRoll:           0
    readonly property real      _defaultPitch:          0
    readonly property real      _defaultHeading:        0
    readonly property real      _defaultAltitudeAMSL:   0
    readonly property real      _defaultGroundSpeed:    0
    readonly property real      _defaultAirSpeed:       0
    readonly property string    _mapName:               "FlightDisplayView"
    readonly property string    _showMapBackgroundKey:  "/showMapBackground"
    readonly property string    _mainIsMapKey:          "MainFlyWindowIsMap"
    readonly property string    _PIPVisibleKey:         "IsPIPVisible"

    function setStates() {
        QGroundControl.saveBoolGlobalSetting(_mainIsMapKey, _mainIsMap)
        if(_mainIsMap) {
            //-- Adjust Margins
            _flightMapContainer.state   = "fullMode"
            _flightVideo.state          = "pipMode"
            //-- Save/Restore Map Zoom Level
            if(_savedZoomLevel != 0)
                _flightMap.zoomLevel = _savedZoomLevel
            else
                _savedZoomLevel = _flightMap.zoomLevel
        } else {
            //-- Adjust Margins
            _flightMapContainer.state   = "pipMode"
            _flightVideo.state          = "fullMode"
            //-- Set Map Zoom Level
            _savedZoomLevel = _flightMap.zoomLevel
            _flightMap.zoomLevel = _savedZoomLevel - 3
        }
    }

    function setPipVisibility(state) {
        _isPipVisible = state;
        QGroundControl.saveBoolGlobalSetting(_PIPVisibleKey, state)
    }

    function isInstrumentRight() {
        if(QGroundControl.corePlugin.options.instrumentWidget) {
            if(QGroundControl.corePlugin.options.instrumentWidget.source.toString().length) {
                switch(QGroundControl.corePlugin.options.instrumentWidget.widgetPosition) {
                case CustomInstrumentWidget.POS_TOP_LEFT:
                case CustomInstrumentWidget.POS_BOTTOM_LEFT:
                case CustomInstrumentWidget.POS_CENTER_LEFT:
                    return false;
                }
            }
        }
        return true;
    }

    PlanMasterController {
        id:                     masterController
        Component.onCompleted:  start(true /* flyView */)
    }

    BuiltInPreFlightCheckModel {
        id: preFlightCheckModel
    }

    Connections {
        target:                     _missionController
        onResumeMissionUploadFail:  guidedActionsController.confirmAction(guidedActionsController.actionResumeMissionUploadFail)
    }

    Component.onCompleted: {
        setStates()
        if(QGroundControl.corePlugin.options.flyViewOverlay.toString().length) {
            flyViewOverlay.source = QGroundControl.corePlugin.options.flyViewOverlay
        }
    }

    // The following code is used to track vehicle states such that we prompt to remove mission from vehicle when mission completes

    property bool vehicleArmed:                 _activeVehicle ? _activeVehicle.armed : true // true here prevents pop up from showing during shutdown
    property bool vehicleWasArmed:              false
    property bool vehicleInMissionFlightMode:   _activeVehicle ? (_activeVehicle.flightMode === _activeVehicle.missionFlightMode) : false
    property bool promptForMissionRemove:       false

    onVehicleArmedChanged: {
        if (vehicleArmed) {
            if (!promptForMissionRemove) {
                promptForMissionRemove = vehicleInMissionFlightMode
                vehicleWasArmed = true
            }
        } else {
            if (promptForMissionRemove && (_missionController.containsItems || _geoFenceController.containsItems || _rallyPointController.containsItems)) {
                // ArduPilot has a strange bug which prevents mission clear from working at certain times, so we can't show this dialog
                if (!_activeVehicle.apmFirmware) {
                    root.showDialog(missionCompleteDialogComponent, qsTr("Flight Plan complete"), showDialogDefaultWidth, StandardButton.Close)
                }
            }
            promptForMissionRemove = false
        }
    }

    onVehicleInMissionFlightModeChanged: {
        if (!promptForMissionRemove && vehicleArmed) {
            promptForMissionRemove = true
        }
    }

    Component {
        id: missionCompleteDialogComponent

        QGCViewDialog {
            property var activeVehicleCopy: _activeVehicle
            onActiveVehicleCopyChanged:
                if (!activeVehicleCopy) {
                    hideDialog()
                }

            QGCFlickable {
                anchors.fill:   parent
                contentHeight:  column.height

                ColumnLayout {
                    id:                 column
                    anchors.margins:    _margins
                    anchors.left:       parent.left
                    anchors.right:      parent.right

                    ColumnLayout {
                        Layout.fillWidth:   true
                        spacing:            ScreenTools.defaultFontPixelHeight
                        visible:            !_activeVehicle.connectionLost || !_guidedController.showResumeMission

                        QGCLabel {
                            Layout.fillWidth:       true
                            text:                   qsTr("%1 Images Taken").arg(_activeVehicle.cameraTriggerPoints.count)
                            horizontalAlignment:    Text.AlignHCenter
                            visible:                _activeVehicle.cameraTriggerPoints.count != 0
                        }

                        QGCButton {
                            Layout.fillWidth:   true
                            text:               qsTr("Remove plan from vehicle")
                            onClicked: {
                                _planMasterController.removeAllFromVehicle()
                                hideDialog()
                            }
                        }

                        QGCButton {
                            Layout.fillWidth:   true
                            Layout.alignment:   Qt.AlignHCenter
                            text:               qsTr("Leave plan on vehicle")
                            onClicked:          hideDialog()
                        }

                        Rectangle {
                            Layout.fillWidth:   true
                            color:              qgcPal.text
                            height:             1
                        }

                        QGCButton {
                            Layout.fillWidth:   true
                            Layout.alignment:   Qt.AlignHCenter
                            text:               qsTr("Resume Mission From Waypoint %1").arg(_guidedController._resumeMissionIndex)
                            visible:            _guidedController.showResumeMission

                            onClicked: {
                                guidedController.executeAction(_guidedController.actionResumeMission, null, null)
                                hideDialog()
                            }
                        }

                        QGCLabel {
                            Layout.fillWidth:   true
                            wrapMode:           Text.WordWrap
                            text:               qsTr("Resume Mission will rebuild the current mission from the last flown waypoint and upload it to the vehicle for the next flight.")
                            visible:            _guidedController.showResumeMission
                        }

                        QGCLabel {
                            Layout.fillWidth:   true
                            wrapMode:           Text.WordWrap
                            color:              qgcPal.warningText
                            text:               qsTr("If you are changing batteries for Resume Mission do not disconnect from the vehicle when communication is lost.")
                            visible:            _guidedController.showResumeMission
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth:   true
                        spacing:            ScreenTools.defaultFontPixelHeight
                        visible:            _activeVehicle.connectionLost && _guidedController.showResumeMission

                        QGCLabel {
                            Layout.fillWidth:   true
                            wrapMode:           Text.WordWrap
                            color:              qgcPal.warningText
                            text:               qsTr("If you are changing batteries for Resume Mission do not disconnect from the vehicle.")
                        }
                    }
                }
            }
        }
    }

    Window {
        id:             videoWindow
        width:          !_mainIsMap ? _panel.width  : _pipSize
        height:         !_mainIsMap ? _panel.height : _pipSize * (9/16)
        visible:        false

        Item {
            id:             videoItem
            anchors.fill:   parent
        }

        onClosing: {
            _flightVideo.state = "unpopup"
            videoWindow.visible = false
        }
    }

    /* This timer will startVideo again after the popup window appears and is loaded.
     * Such approach was the only one to avoid a crash for windows users
     */
    Timer {
      id: videoPopUpTimer
      interval: 2000;
      running: false;
      repeat: false
      onTriggered: {
          // If state is popup, the next one will be popup-finished
          if (_flightVideo.state ==  "popup") {
            _flightVideo.state = "popup-finished"
          }
          QGroundControl.videoManager.startVideo()
      }
    }

    QGCMapPalette { id: mapPal; lightColors: _mainIsMap ? _flightMap.isSatelliteMap : true }

    QGCViewPanel {
        id:             _panel
        anchors.fill:   parent

        //-- Map View
        //   For whatever reason, if FlightDisplayViewMap is the _panel item, changing
        //   width/height has no effect.
        Item {
            id: _flightMapContainer
            z:  _mainIsMap ? _panel.z + 1 : _panel.z + 2
            anchors.left:   _panel.left
            anchors.bottom: _panel.bottom
            visible:        _mainIsMap || _isPipVisible && !QGroundControl.videoManager.fullScreen
            width:          _mainIsMap ? _panel.width  : _pipSize
            height:         _mainIsMap ? _panel.height : _pipSize * (9/16)
            states: [
                State {
                    name:   "pipMode"
                    PropertyChanges {
                        target:             _flightMapContainer
                        anchors.margins:    ScreenTools.defaultFontPixelHeight
                    }
                },
                State {
                    name:   "fullMode"
                    PropertyChanges {
                        target:             _flightMapContainer
                        anchors.margins:    0
                    }
                }
            ]
            FlightDisplayViewMap {
                id:                         _flightMap
                anchors.fill:               parent
                planMasterController:       masterController
                guidedActionsController:    _guidedController
                flightWidgets:              flightDisplayViewWidgets
                rightPanelWidth:            ScreenTools.defaultFontPixelHeight * 9
                qgcView:                    root
                multiVehicleView:           !singleVehicleView.checked
                scaleState:                 (_mainIsMap && flyViewOverlay.item) ? (flyViewOverlay.item.scaleState ? flyViewOverlay.item.scaleState : "bottomMode") : "bottomMode"
            }
        }

        //-- Video View
        Item {
            id:             _flightVideo
            z:              _mainIsMap ? _panel.z + 2 : _panel.z + 1
            width:          !_mainIsMap ? _panel.width  : _pipSize
            height:         !_mainIsMap ? _panel.height : _pipSize * (9/16)
            anchors.left:   _panel.left
            anchors.bottom: _panel.bottom
            visible:        QGroundControl.videoManager.hasVideo && (!_mainIsMap || _isPipVisible)

            onParentChanged: {
                /* If video comes back from popup
                 * correct anchors.
                 * Such thing is not possible with ParentChange.
                 */
                if(parent == _panel) {
                    // Do anchors again after popup
                    anchors.left =       _panel.left
                    anchors.bottom =     _panel.bottom
                    anchors.margins =    ScreenTools.defaultFontPixelHeight
                }
            }

            states: [
                State {
                    name:   "pipMode"
                    PropertyChanges {
                        target: _flightVideo
                        anchors.margins: ScreenTools.defaultFontPixelHeight
                    }
                    PropertyChanges {
                        target: _flightVideoPipControl
                        inPopup: false
                    }
                },
                State {
                    name:   "fullMode"
                    PropertyChanges {
                        target: _flightVideo
                        anchors.margins:    0
                    }
                    PropertyChanges {
                        target: _flightVideoPipControl
                        inPopup: false
                    }
                },
                State {
                    name: "popup"
                    StateChangeScript {
                        script: {
                            // Stop video, restart it again with Timer
                            // Avoiding crashs if ParentChange is not yet done
                            QGroundControl.videoManager.stopVideo()
                            videoPopUpTimer.running = true
                        }
                    }
                    PropertyChanges {
                        target: _flightVideoPipControl
                        inPopup: true
                    }
                },
                State {
                    name: "popup-finished"
                    ParentChange {
                        target: _flightVideo
                        parent: videoItem
                        x: 0
                        y: 0
                        width: videoItem.width
                        height: videoItem.height
                    }
                },
                State {
                    name: "unpopup"
                    StateChangeScript {
                        script: {
                            QGroundControl.videoManager.stopVideo()
                            videoPopUpTimer.running = true
                        }
                    }
                    ParentChange {
                        target: _flightVideo
                        parent: _panel
                    }
                    PropertyChanges {
                        target: _flightVideoPipControl
                        inPopup: false
                    }
                }
            ]
            //-- Video Streaming
            FlightDisplayViewVideo {
                id:             videoStreaming
                anchors.fill:   parent
                visible:        QGroundControl.videoManager.isGStreamer
            }
            //-- UVC Video (USB Camera or Video Device)
            Loader {
                id:             cameraLoader
                anchors.fill:   parent
                visible:        !QGroundControl.videoManager.isGStreamer
                source:         QGroundControl.videoManager.uvcEnabled ? "qrc:/qml/FlightDisplayViewUVC.qml" : "qrc:/qml/FlightDisplayViewDummy.qml"
            }
        }

        QGCPipable {
            id:                 _flightVideoPipControl
            z:                  _flightVideo.z + 3
            width:              _pipSize
            height:             _pipSize * (9/16)
            anchors.left:       _panel.left
            anchors.bottom:     _panel.bottom
            anchors.margins:    ScreenTools.defaultFontPixelHeight
            visible:            QGroundControl.videoManager.hasVideo && !QGroundControl.videoManager.fullScreen && _flightVideo.state != "popup"
            isHidden:           !_isPipVisible
            isDark:             isBackgroundDark
            enablePopup:        _mainIsMap
            onActivated: {
                _mainIsMap = !_mainIsMap
                setStates()
            }
            onHideIt: {
                setPipVisibility(!state)
            }
            onPopup: {
                videoWindow.visible = true
                _flightVideo.state = "popup"
            }
            onNewWidth: {
                _pipSize = newWidth
            }
        }

        Row {
            id:                     singleMultiSelector
            anchors.topMargin:      ScreenTools.toolbarHeight + _margins
            anchors.rightMargin:    _margins
            anchors.right:          parent.right
            anchors.top:            parent.top
            spacing:                ScreenTools.defaultFontPixelWidth
            z:                      _panel.z + 4
            visible:                QGroundControl.multiVehicleManager.vehicles.count > 1

            ExclusiveGroup { id: multiVehicleSelectorGroup }

            QGCRadioButton {
                id:             singleVehicleView
                exclusiveGroup: multiVehicleSelectorGroup
                text:           qsTr("Single")
                checked:        true
                textColor:      mapPal.text
            }

            QGCRadioButton {
                exclusiveGroup: multiVehicleSelectorGroup
                text:           qsTr("Multi-Vehicle")
                textColor:      mapPal.text
            }
        }

        FlightDisplayViewWidgets {
            id:                 flightDisplayViewWidgets
            z:                  _panel.z + 4
            height:             ScreenTools.availableHeight - (singleMultiSelector.visible ? singleMultiSelector.height + _margins : 0)
            anchors.left:       parent.left
            anchors.right:      altitudeSlider.visible ? altitudeSlider.left : parent.right
            anchors.bottom:     parent.bottom
            qgcView:            root
            useLightColors:     isBackgroundDark
            missionController:  _missionController
            visible:            singleVehicleView.checked && !QGroundControl.videoManager.fullScreen
        }

        //-------------------------------------------------------------------------
        //-- Loader helper for plugins to overlay elements over the fly view
        Loader {
            id:                 flyViewOverlay
            z:                  flightDisplayViewWidgets.z + 1
            visible:            !QGroundControl.videoManager.fullScreen
            height:             ScreenTools.availableHeight
            anchors.left:       parent.left
            anchors.right:      altitudeSlider.visible ? altitudeSlider.left : parent.right
            anchors.bottom:     parent.bottom

            property var qgcView: root
        }

        MultiVehicleList {
            anchors.margins:            _margins
            anchors.top:                singleMultiSelector.bottom
            anchors.right:              parent.right
            anchors.bottom:             parent.bottom
            width:                      ScreenTools.defaultFontPixelWidth * 30
            visible:                    !singleVehicleView.checked && !QGroundControl.videoManager.fullScreen
            z:                          _panel.z + 4
            guidedActionsController:    _guidedController
        }

        //-- Virtual Joystick
        Loader {
            id:                         virtualJoystickMultiTouch
            z:                          _panel.z + 5
            width:                      parent.width  - (_flightVideoPipControl.width / 2)
            height:                     Math.min(ScreenTools.availableHeight * 0.25, ScreenTools.defaultFontPixelWidth * 16)
            visible:                    (_virtualJoystick ? _virtualJoystick.value : false) && !QGroundControl.videoManager.fullScreen && !(_activeVehicle ? _activeVehicle.highLatencyLink : false)
            anchors.bottom:             _flightVideoPipControl.top
            anchors.bottomMargin:       ScreenTools.defaultFontPixelHeight * 2
            anchors.horizontalCenter:   flightDisplayViewWidgets.horizontalCenter
            source:                     "qrc:/qml/VirtualJoystick.qml"
            active:                     (_virtualJoystick ? _virtualJoystick.value : false) && !(_activeVehicle ? _activeVehicle.highLatencyLink : false)

            property bool useLightColors: isBackgroundDark

            property Fact _virtualJoystick: QGroundControl.settingsManager.appSettings.virtualJoystick
        }

        ToolStrip {
            visible:            (_activeVehicle ? _activeVehicle.guidedModeSupported : true) && !QGroundControl.videoManager.fullScreen
            id:                 toolStrip
            anchors.leftMargin: isInstrumentRight() ? ScreenTools.defaultFontPixelWidth : undefined
            anchors.left:       isInstrumentRight() ? _panel.left : undefined
            anchors.rightMargin:isInstrumentRight() ? undefined : ScreenTools.defaultFontPixelWidth
            anchors.right:      isInstrumentRight() ? undefined : _panel.right
            anchors.topMargin:  ScreenTools.toolbarHeight + (_margins * 2)
            anchors.top:        _panel.top
            z:                  _panel.z + 4
            title:              qsTr("Fly")
            maxHeight:          (_flightVideo.visible ? _flightVideo.y : parent.height) - toolStrip.y
            buttonVisible:      [ _useChecklist, _guidedController.showTakeoff || !_guidedController.showLand, _guidedController.showLand && !_guidedController.showTakeoff, true, true, true ]
            buttonEnabled:      [ _useChecklist && _activeVehicle, _guidedController.showTakeoff, _guidedController.showLand, _guidedController.showRTL, _guidedController.showPause, _anyActionAvailable ]

            property bool _anyActionAvailable: _guidedController.showStartMission || _guidedController.showResumeMission || _guidedController.showChangeAlt || _guidedController.showLandAbort
            property var _actionModel: [
                {
                    title:      _guidedController.startMissionTitle,
                    text:       _guidedController.startMissionMessage,
                    action:     _guidedController.actionStartMission,
                    visible:    _guidedController.showStartMission
                },
                {
                    title:      _guidedController.continueMissionTitle,
                    text:       _guidedController.continueMissionMessage,
                    action:     _guidedController.actionContinueMission,
                    visible:    _guidedController.showContinueMission
                },
                {
                    title:      _guidedController.resumeMissionTitle,
                    text:       _guidedController.resumeMissionMessage,
                    action:     _guidedController.actionResumeMission,
                    visible:    _guidedController.showResumeMission
                },
                {
                    title:      _guidedController.changeAltTitle,
                    text:       _guidedController.changeAltMessage,
                    action:     _guidedController.actionChangeAlt,
                    visible:    _guidedController.showChangeAlt
                },
                {
                    title:      _guidedController.landAbortTitle,
                    text:       _guidedController.landAbortMessage,
                    action:     _guidedController.actionLandAbort,
                    visible:    _guidedController.showLandAbort
                }
            ]

            model: [
                {
                    name:               "Checklist",
                    iconSource:         "/qmlimages/check.svg",
                    dropPanelComponent: checklistDropPanel
                },
                {
                    name:       _guidedController.takeoffTitle,
                    iconSource: "/res/takeoff.svg",
                    action:     _guidedController.actionTakeoff
                },
                {
                    name:       _guidedController.landTitle,
                    iconSource: "/res/land.svg",
                    action:     _guidedController.actionLand
                },
                {
                    name:       _guidedController.rtlTitle,
                    iconSource: "/res/rtl.svg",
                    action:     _guidedController.actionRTL
                },
                {
                    name:       _guidedController.pauseTitle,
                    iconSource: "/res/pause-mission.svg",
                    action:     _guidedController.actionPause
                },
                {
                    name:       qsTr("Action"),
                    iconSource: "/res/action.svg",
                    action:     -1
                }
            ]

            onClicked: {
                guidedActionsController.closeAll()
                var action = model[index].action
                if (action === -1) {
                    guidedActionList.model   = _actionModel
                    guidedActionList.visible = true
                } else {
                    _guidedController.confirmAction(action)
                }
            }
        }

        GuidedActionsController {
            id:                 guidedActionsController
            missionController:  _missionController
            confirmDialog:      guidedActionConfirm
            actionList:         guidedActionList
            altitudeSlider:     _altitudeSlider
            z:                  _flightVideoPipControl.z + 1

            onShowStartMissionChanged: {
                if (showStartMission) {
                    confirmAction(actionStartMission)
                }
            }

            onShowContinueMissionChanged: {
                if (showContinueMission) {
                    confirmAction(actionContinueMission)
                }
            }

            onShowLandAbortChanged: {
                if (showLandAbort) {
                    confirmAction(actionLandAbort)
                }
            }

            /// Close all dialogs
            function closeAll() {
                mainWindow.enableToolbar()
                rootLoader.sourceComponent  = null
                guidedActionConfirm.visible = false
                guidedActionList.visible    = false
                altitudeSlider.visible      = false
            }
        }

        GuidedActionConfirm {
            id:                         guidedActionConfirm
            anchors.margins:            _margins
            anchors.bottom:             parent.bottom
            anchors.horizontalCenter:   parent.horizontalCenter
            guidedController:           _guidedController
            altitudeSlider:             _altitudeSlider
        }

        GuidedActionList {
            id:                         guidedActionList
            anchors.margins:            _margins
            anchors.bottom:             parent.bottom
            anchors.horizontalCenter:   parent.horizontalCenter
            guidedController:           _guidedController
        }

        //-- Altitude slider
        GuidedAltitudeSlider {
            id:                 altitudeSlider
            anchors.margins:    _margins
            anchors.right:      parent.right
            anchors.topMargin:  ScreenTools.toolbarHeight + _margins
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            z:                  _guidedController.z
            radius:             ScreenTools.defaultFontPixelWidth / 2
            width:              ScreenTools.defaultFontPixelWidth * 10
            color:              qgcPal.window
            visible:            false
        }
    }

    //-- Airspace Indicator
    Rectangle {
        id:             airspaceIndicator
        width:          airspaceRow.width + (ScreenTools.defaultFontPixelWidth * 3)
        height:         airspaceRow.height * 1.25
        color:          qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1,1,1,0.95) : Qt.rgba(0,0,0,0.75)
        visible:        QGroundControl.airmapSupported && _mainIsMap && flightPermit && flightPermit !== AirspaceFlightPlanProvider.PermitNone && !messageArea.visible && !criticalMmessageArea.visible
        radius:         3
        border.width:   1
        border.color:   qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0,0,0,0.35) : Qt.rgba(1,1,1,0.35)
        anchors.top:    parent.top
        anchors.topMargin: ScreenTools.toolbarHeight + (ScreenTools.defaultFontPixelHeight * 0.25)
        anchors.horizontalCenter: parent.horizontalCenter
        Row {
            id: airspaceRow
            spacing: ScreenTools.defaultFontPixelWidth
            anchors.centerIn: parent
            QGCLabel { text: airspaceIndicator.providerName+":"; anchors.verticalCenter: parent.verticalCenter; }
            QGCLabel {
                text: {
                    if(airspaceIndicator.flightPermit) {
                        if(airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitPending)
                            return qsTr("Approval Pending")
                        if(airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitAccepted || airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitNotRequired)
                            return qsTr("Flight Approved")
                        if(airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitRejected)
                            return qsTr("Flight Rejected")
                    }
                    return ""
                }
                color: {
                    if(airspaceIndicator.flightPermit) {
                        if(airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitPending)
                            return qgcPal.colorOrange
                        if(airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitAccepted || airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitNotRequired)
                            return qgcPal.colorGreen
                    }
                    return qgcPal.colorRed
                }
                anchors.verticalCenter: parent.verticalCenter;
            }
        }
        property var  flightPermit: QGroundControl.airmapSupported ? QGroundControl.airspaceManager.flightPlan.flightPermitStatus : null
        property string  providerName: QGroundControl.airspaceManager.providerName
    }

    //-- Checklist GUI
    Component {
        id: checklistDropPanel
        PreFlightCheckList {
            model: preFlightCheckModel
        }
    }


    property bool sideWindShow: false
    Item {
        id: drawer
        anchors.fill: parent
        anchors.topMargin:  ScreenTools.toolbarHeight+10
        anchors.bottomMargin: 10


        function showWinShow(){
            recloder.source = "qrc:/qml/FlightDisplayView_Drawer.qml"
        }
        function showNothing()
        {
            recloder.source = ""
        }
        Loader{
            id:recloder
            anchors.fill: sideWin
            z:_panel.z+2
        }
        Rectangle {
            id: sideWin
            color:"#C6C2C6" //如果希望窗口弹出时为不透明则使用ff
            x: parent.width //这是弹窗的位置坐标，此处的做法是将弹窗隐藏在主界面的左侧
            width: parent.width*0.2 //弹窗的大小
            height: parent.height
            opacity: 0.8
            radius:20
            z:  _panel.z + 1
            //这是弹窗弹出的效果，相比C++实现的动态效果，这里显得十分“轻巧”;看字面的意思也可以猜测出是弹窗横坐标发生变化时的行为
            Behavior on x {
                NumberAnimation { //一个动画的类型，具体可以查看一下qt助手，本人也是在学习中
                    duration: 300 //动画持续时间，以ms计算
                }
            }
        }
        Rectangle { //弹窗的“按钮”，此处是因为使用了图标所以用Rectangle来实现
                id: popUpBtn
                color: "#00000000" //设置此”按钮“为全透明
                width: 64
                height: 64
                anchors.right:  sideWin.left//此处的锚布局设置为弹窗的右侧
                anchors.verticalCenter: sideWin.verticalCenter //锚布局为弹窗的垂直中线上

                Image {
                    anchors.centerIn: parent
                    source: "/qmlimages/VehicleSummaryIcon.png"

                    MouseArea { //此处是实现点击的关键(所以说Qml中很多时候不会直接使用Button，因为通过自己的样式选择可以轻易实现”按钮“功能)
                        anchors.fill: parent

                        onPressed: {
                            popUpBtn.color = "#ff40598a" // 此处是为了体现”按钮“点击时的背景效果
                        }

                        onReleased: {
                            popUpBtn.color = "#00000000" // 恢复按钮未被按下时的背景效果
                        }

                        onClicked: {
                            sideWindShow = !sideWindShow
                            // 三目运算符的用法，在此处改变弹窗的位置坐标，此时弹窗的行为即会触发出现动态效果
                            sideWindShow ? sideWin.x = root.width - sideWin.width-10 : sideWin.x = root.width
                            sideWindShow ? parent.source = "/qmlimages/VehicleSummaryIcon.png" : parent.source = "/qmlimages/VehicleSummaryIcon.png"
                            sideWindShow ? drawer.showWinShow():drawer.showNothing()

                        }
                    }
                }

            }
    }
}
