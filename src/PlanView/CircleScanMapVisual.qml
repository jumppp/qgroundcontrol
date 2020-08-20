/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtLocation       5.3
import QtPositioning    5.3

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FlightMap     1.0

/// Survey Complex Mission Item visuals
Item {
    id: _root

    property var map        ///< Map control to place item in
    property var qgcView    ///< QGCView to use for popping dialogs
    property var _missionItem:      object
    property var _structurePolygon: object.structurePolygon
    property var _flightPolygon:    object.flightPolygon
    property var _entryCoordinate
    property var _exitCoordinate

    signal clicked(int sequenceNumber)

    function _addVisualElements() {
        _entryCoordinate = entryPointComponent.createObject(map)
        _exitCoordinate = exitPointComponent.createObject(map)
        map.addMapItem(_entryCoordinate)
        map.addMapItem(_exitCoordinate)
    }

    function _destroyVisualElements() {
        _entryCoordinate.destroy()
        _exitCoordinate.destroy()
    }

    /// Add an initial 4 sided polygon if there is none
    function _addInitialPolygon() {
        if (_structurePolygon.count < 3) {
            var rect = Qt.rect(map.centerViewport.x, map.centerViewport.y, map.centerViewport.width, map.centerViewport.height)
            rect.x += (rect.width * 0.25) / 2
            rect.y += (rect.height * 0.25) / 2
            rect.width *= 0.75
            rect.height *= 0.75

            var centerCoord = map.toCoordinate(Qt.point(rect.x + (rect.width / 2), rect.y + (rect.height / 2)),   false /* clipToViewPort */)
            var unboundCenter = centerCoord.atDistanceAndAzimuth(0, 0)
            var _circleRadius =_missionItem.circleRadius.value
            var segments = 8
            var angleIncrement = 360 / segments
            var angle = 0
            _structurePolygon.clear()
            for (var i=0; i<segments; i++) {
                var vertex = unboundCenter.atDistanceAndAzimuth(_circleRadius, angle)
                _structurePolygon.appendVertex(vertex)
                angle += angleIncrement
            }
        }
    }

    Component.onCompleted: {
        _addInitialPolygon()
        _addVisualElements()
    }

    Component.onDestruction: {
        _destroyVisualElements()
    }

    QGCMapPolygonCircleVisuals {
        qgcView:            _root.qgcView
        mapControl:         map
        mapPolygon:         _structurePolygon
        interactive:        _missionItem.isCurrentItem
        borderWidth:        0
        borderColor:        "black"
        interiorColor:      "green"
        interiorOpacity:    0
    }

    QGCMapPolygonCircleVisuals {
        qgcView:            _root.qgcView
        mapControl:         map
        mapPolygon:         _flightPolygon
        interactive:        false
        borderWidth:        2
        borderColor:        "white"
    }

    // Entry point
    Component {
        id: entryPointComponent

        MapQuickItem {
            anchorPoint.x:  sourceItem.anchorPointX
            anchorPoint.y:  sourceItem.anchorPointY
            z:              QGroundControl.zOrderMapItems
            coordinate:     _missionItem.coordinate
            visible:        _missionItem.exitCoordinate.isValid

            sourceItem: MissionItemIndexLabel {
                index:      _missionItem.sequenceNumber
                label:      "Entry"
                checked:    _missionItem.isCurrentItem
                onClicked:  _root.clicked(_missionItem.sequenceNumber)
            }
        }
    }

    // Exit point
    Component {
        id: exitPointComponent

        MapQuickItem {
            anchorPoint.x:  sourceItem.anchorPointX
            anchorPoint.y:  sourceItem.anchorPointY
            z:              QGroundControl.zOrderMapItems
            coordinate:     _missionItem.exitCoordinate
            visible:        _missionItem.exitCoordinate.isValid

            sourceItem: MissionItemIndexLabel {
                index:      _missionItem.lastSequenceNumber
                label:      "Exit"
                checked:    _missionItem.isCurrentItem
                onClicked:  _root.clicked(_missionItem.sequenceNumber)
            }
        }
    }
}
