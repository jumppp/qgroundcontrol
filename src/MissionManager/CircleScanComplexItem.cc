/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "CircleScanComplexItem.h"
#include "JsonHelper.h"
#include "MissionController.h"
#include "QGCGeo.h"
#include "QGroundControlQmlGlobal.h"
#include "QGCQGeoCoordinate.h"
#include "SettingsManager.h"
#include "AppSettings.h"
#include "QGCQGeoCoordinate.h"

#include <QPolygonF>

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

QGC_LOGGING_CATEGORY(CircleScanComplexItemLog, "CircleScanComplexItemLog")

const char* CircleScanComplexItem::settingsGroup =               "CircleScan";
const char* CircleScanComplexItem::altitudeName =                "Altitude";
const char* CircleScanComplexItem::structureHeightName =         "StructureHeight";
const char* CircleScanComplexItem::layersName =                  "Layers";
const char* CircleScanComplexItem::gimbalPitchName =             "GimbalPitch";

const char* CircleScanComplexItem::jsonComplexItemTypeValue =    "CircleScan";
const char* CircleScanComplexItem::_jsonCameraCalcKey =          "CameraCalc";
const char* CircleScanComplexItem::_jsonAltitudeRelativeKey =    "altitudeRelative";
CircleScanComplexItem::CircleScanComplexItem(Vehicle* vehicle, bool flyView, const QString& kmlOrShpFile, QObject* parent)
    : ComplexMissionItem        (vehicle, flyView, parent)
    , _metaDataMap              (FactMetaData::createMapFromJsonFile(QStringLiteral(":/src/MissionManager/CircleScan.SettingsGroup.json"), this /* QObject parent */))
    , _sequenceNumber           (0)
    , _dirty                    (false)
    , _altitudeRelative         (true)
    , _entryVertex              (0)
    , _ignoreRecalc             (false)
    , _scanDistance             (0.0)
    , _radius                   (50.0)
    , _cameraShots              (0)
    , _cameraCalc               (vehicle, settingsGroup)
    , _altitudeFact             (settingsGroup, _metaDataMap[altitudeName])
    , _structureHeightFact      (settingsGroup, _metaDataMap[structureHeightName])
    , _layersFact               (settingsGroup, _metaDataMap[layersName])
    , _gimbalPitchFact          (settingsGroup, _metaDataMap[gimbalPitchName])
{
    _editorQml = "qrc:/qml/CircleScanEditor.qml";

    _altitudeFact.setRawValue(qgcApp()->toolbox()->settingsManager()->appSettings()->defaultMissionItemAltitude()->rawValue());

    connect(&_altitudeFact,     &Fact::valueChanged, this, &CircleScanComplexItem::_setDirty);
    connect(&_layersFact,       &Fact::valueChanged, this, &CircleScanComplexItem::_setDirty);
    connect(&_gimbalPitchFact,  &Fact::valueChanged, this, &CircleScanComplexItem::_setDirty);

    connect(&_layersFact,                           &Fact::valueChanged,    this, &CircleScanComplexItem::_recalcLayerInfo);
    connect(&_structureHeightFact,                  &Fact::valueChanged,    this, &CircleScanComplexItem::_recalcLayerInfo);
    connect(_cameraCalc.adjustedFootprintFrontal(), &Fact::valueChanged,    this, &CircleScanComplexItem::_recalcLayerInfo);

    connect(this, &CircleScanComplexItem::altitudeRelativeChanged,       this, &CircleScanComplexItem::_setDirty);
    connect(this, &CircleScanComplexItem::altitudeRelativeChanged,       this, &CircleScanComplexItem::coordinateHasRelativeAltitudeChanged);
    connect(this, &CircleScanComplexItem::altitudeRelativeChanged,       this, &CircleScanComplexItem::exitCoordinateHasRelativeAltitudeChanged);

    connect(&_altitudeFact, &Fact::valueChanged, this, &CircleScanComplexItem::_updateCoordinateAltitudes);

    connect(&_structurePolygon, &QGCMapPolygon::dirtyChanged,   this, &CircleScanComplexItem::_polygonDirtyChanged);
    connect(&_structurePolygon, &QGCMapPolygon::pathChanged,    this, &CircleScanComplexItem::_rebuildFlightPolygon);

    connect(&_structurePolygon, &QGCMapPolygon::countChanged,   this, &CircleScanComplexItem::_updateLastSequenceNumber);
    connect(&_layersFact,       &Fact::valueChanged,            this, &CircleScanComplexItem::_rebuildFlightPolygon);
    connect(&_layersFact,       &Fact::valueChanged,            this, &CircleScanComplexItem::_updateLastSequenceNumber);

    connect(&_flightPolygon,    &QGCMapPolygon::pathChanged,    this, &CircleScanComplexItem::_flightPathChanged);

    connect(_cameraCalc.distanceToSurface(),    &Fact::valueChanged,                this, &CircleScanComplexItem::_rebuildFlightPolygon);

    connect(&_flightPolygon,                        &QGCMapPolygon::pathChanged,    this, &CircleScanComplexItem::_recalcCameraShots);
    connect(_cameraCalc.adjustedFootprintSide(),    &Fact::valueChanged,            this, &CircleScanComplexItem::_recalcCameraShots);
    connect(&_layersFact,                           &Fact::valueChanged,            this, &CircleScanComplexItem::_recalcCameraShots);

    connect(&_cameraCalc, &CameraCalc::isManualCameraChanged, this, &CircleScanComplexItem::_updateGimbalPitch);

    _recalcLayerInfo();

    if (!kmlOrShpFile.isEmpty()) {
        _structurePolygon.loadKMLOrSHPFile(kmlOrShpFile);
        _structurePolygon.setDirty(false);
    }

    setDirty(false);
}

void CircleScanComplexItem::_setScanDistance(double scanDistance)
{
    if (!qFuzzyCompare(_scanDistance, scanDistance)) {
        _scanDistance = scanDistance;
        emit complexDistanceChanged();
    }
}

void CircleScanComplexItem::_setCameraShots(int cameraShots)
{
    if (_cameraShots != cameraShots) {
        _cameraShots = cameraShots;
        emit cameraShotsChanged(this->cameraShots());
    }
}

void CircleScanComplexItem::_clearInternal(void)
{
    setDirty(true);

    emit specifiesCoordinateChanged();
    emit lastSequenceNumberChanged(lastSequenceNumber());
}

void CircleScanComplexItem::_updateLastSequenceNumber(void)
{
    emit lastSequenceNumberChanged(lastSequenceNumber());
}

int CircleScanComplexItem::lastSequenceNumber(void) const
{
    // Each structure layer contains:
    //  1 waypoint for each polygon vertex + 1 to go back to first polygon vertex for each layer
    //  Two commands for camera trigger start/stop + 2
//    int layerItemCount = _flightPolygon.count() + 1;

//    int multiLayerItemCount = layerItemCount * _layersFact.rawValue().toInt();

//    int itemCount = multiLayerItemCount;    // +2 for ROI_WPNEXT_OFFSET and ROI_NONE commands

//    return _sequenceNumber + itemCount - 1;
    return _flightPolygon.count();
}

void CircleScanComplexItem::setDirty(bool dirty)
{
    if (_dirty != dirty) {
        _dirty = dirty;
        emit dirtyChanged(_dirty);
    }
}

void CircleScanComplexItem::save(QJsonArray&  missionItems)
{
    QJsonObject saveObject;

    // Header
    saveObject[JsonHelper::jsonVersionKey] =                    2;
    saveObject[VisualMissionItem::jsonTypeKey] =                VisualMissionItem::jsonTypeComplexItemValue;
    saveObject[ComplexMissionItem::jsonComplexItemTypeKey] =    jsonComplexItemTypeValue;

    saveObject[altitudeName] =              _altitudeFact.rawValue().toDouble();
    saveObject[structureHeightName] =       _structureHeightFact.rawValue().toDouble();
    saveObject[_jsonAltitudeRelativeKey] =  _altitudeRelative;
    saveObject[layersName] =                _layersFact.rawValue().toDouble();
    saveObject[gimbalPitchName] =           _gimbalPitchFact.rawValue().toDouble();

    QJsonObject cameraCalcObject;
    _cameraCalc.save(cameraCalcObject);
    saveObject[_jsonCameraCalcKey] = cameraCalcObject;

    _structurePolygon.saveToJson(saveObject);

    missionItems.append(saveObject);
}

void CircleScanComplexItem::setSequenceNumber(int sequenceNumber)
{
    if (_sequenceNumber != sequenceNumber) {
        _sequenceNumber = sequenceNumber;
        emit sequenceNumberChanged(sequenceNumber);
        emit lastSequenceNumberChanged(lastSequenceNumber());
    }
}

bool CircleScanComplexItem::load(const QJsonObject& complexObject, int sequenceNumber, QString& errorString)
{
    QList<JsonHelper::KeyValidateInfo> keyInfoList = {
        { JsonHelper::jsonVersionKey,                   QJsonValue::Double, true },
        { VisualMissionItem::jsonTypeKey,               QJsonValue::String, true },
        { ComplexMissionItem::jsonComplexItemTypeKey,   QJsonValue::String, true },
        { QGCMapPolygon::jsonPolygonKey,                QJsonValue::Array,  true },
        { altitudeName,                                 QJsonValue::Double, true },
        { structureHeightName,                          QJsonValue::Double, true },
        { _jsonAltitudeRelativeKey,                     QJsonValue::Bool,   true },
        { layersName,                                   QJsonValue::Double, true },
        { gimbalPitchName,                              QJsonValue::Double, false },    // This value was added after initial implementation so may be missing from older files
        { _jsonCameraCalcKey,                           QJsonValue::Object, true },
    };
    if (!JsonHelper::validateKeys(complexObject, keyInfoList, errorString)) {
        return false;
    }

    _structurePolygon.clear();

    QString itemType = complexObject[VisualMissionItem::jsonTypeKey].toString();
    QString complexType = complexObject[ComplexMissionItem::jsonComplexItemTypeKey].toString();
    if (itemType != VisualMissionItem::jsonTypeComplexItemValue || complexType != jsonComplexItemTypeValue) {
        errorString = tr("%1 does not support loading this complex mission item type: %2:%3").arg(qgcApp()->applicationName()).arg(itemType).arg(complexType);
        return false;
    }

    int version = complexObject[JsonHelper::jsonVersionKey].toInt();
    if (version != 2) {
        errorString = tr("%1 complex item version %2 not supported").arg(jsonComplexItemTypeValue).arg(version);
        return false;
    }

    setSequenceNumber(sequenceNumber);

    // Load CameraCalc first since it will trigger camera name change which will trounce gimbal angles
    if (!_cameraCalc.load(complexObject[_jsonCameraCalcKey].toObject(), errorString)) {
        return false;
    }

    _altitudeFact.setRawValue       (complexObject[altitudeName].toDouble());
    _layersFact.setRawValue         (complexObject[layersName].toDouble());
    _structureHeightFact.setRawValue(complexObject[structureHeightName].toDouble());

    _altitudeRelative = complexObject[_jsonAltitudeRelativeKey].toBool(true);

    double gimbalPitchValue = 0;
    if (complexObject.contains(gimbalPitchName)) {
        gimbalPitchValue = complexObject[gimbalPitchName].toDouble();
    }
    _gimbalPitchFact.setRawValue(gimbalPitchValue);

    if (!_structurePolygon.loadFromJson(complexObject, true /* required */, errorString)) {
        _structurePolygon.clear();
        return false;
    }

    return true;
}

void CircleScanComplexItem::_flightPathChanged(void)
{
    // Calc bounding cube
    double north = 0.0;
    double south = 180.0;
    double east  = 0.0;
    double west  = 360.0;
    double bottom = 100000.;
    double top = 0.;
    QList<QGeoCoordinate> vertices = _flightPolygon.coordinateList();
    for (int i = 0; i < vertices.count(); i++) {
        QGeoCoordinate vertex = vertices[i];
        double lat = vertex.latitude()  + 90.0;
        double lon = vertex.longitude() + 180.0;
        north   = fmax(north, lat);
        south   = fmin(south, lat);
        east    = fmax(east,  lon);
        west    = fmin(west,  lon);
        bottom  = fmin(bottom, vertex.altitude());
        top     = fmax(top, vertex.altitude());
    }
    //-- Update bounding cube for airspace management control
    _setBoundingCube(QGCGeoBoundingCube(
        QGeoCoordinate(north - 90.0, west - 180.0, bottom),
        QGeoCoordinate(south - 90.0, east - 180.0, top)));

    emit coordinateChanged(coordinate());
    emit exitCoordinateChanged(exitCoordinate());
    emit greatestDistanceToChanged();
}

double CircleScanComplexItem::greatestDistanceTo(const QGeoCoordinate &other) const
{
    double greatestDistance = 0.0;
    QList<QGeoCoordinate> vertices = _flightPolygon.coordinateList();

    for (int i=0; i<vertices.count(); i++) {
        QGeoCoordinate vertex = vertices[i];
        double distance = vertex.distanceTo(other);
        if (distance > greatestDistance) {
            greatestDistance = distance;
        }
    }

    return greatestDistance;
}

bool CircleScanComplexItem::specifiesCoordinate(void) const
{
    return _flightPolygon.count() > 2;
}

void CircleScanComplexItem::appendMissionItems(QList<MissionItem*>& items, QObject* missionItemParent)
{
    int seqNum = _sequenceNumber;
    double baseAltitude = _altitudeFact.rawValue().toDouble();

//    for (int layer=0; layer<_layersFact.rawValue().toInt(); layer++) {
        bool addTriggerStart = false;
        // baseAltitude is the bottom of the first layer. Hence we need to move up half the distance of the camera footprint to center the camera
        // within the layer.
        double layerAltitude = baseAltitude;

        for (int i=0; i<_flightPolygon.count(); i++) {
            QGeoCoordinate vertexCoord = _flightPolygon.vertexCoordinate(i);

            MissionItem* item = new MissionItem(seqNum++,
                                                MAV_CMD_NAV_WAYPOINT,
                                                _altitudeRelative ? MAV_FRAME_GLOBAL_RELATIVE_ALT : MAV_FRAME_GLOBAL,
                                                0,                                          // No hold time
                                                0.0,                                        // No acceptance radius specified
                                                0.0,                                        // Pass through waypoint
                                                std::numeric_limits<double>::quiet_NaN(),   // Yaw unchanged
                                                vertexCoord.latitude(),
                                                vertexCoord.longitude(),
                                                layerAltitude,
                                                true,                                       // autoContinue
                                                false,                                      // isCurrentItem
                                                missionItemParent);
            items.append(item);

            if (addTriggerStart) {
                addTriggerStart = false;
                item = new MissionItem(seqNum++,
                                       MAV_CMD_DO_SET_CAM_TRIGG_DIST,
                                       MAV_FRAME_MISSION,
                                       _cameraCalc.adjustedFootprintSide()->rawValue().toDouble(),  // trigger distance
                                       0,                                                           // shutter integration (ignore)
                                       1,                                                           // trigger immediately when starting
                                       0, 0, 0, 0,                                                  // param 4-7 unused
                                       true,                                                        // autoContinue
                                       false,                                                       // isCurrentItem
                                       missionItemParent);
                items.append(item);
            }
        }

//        QGeoCoordinate vertexCoord = _flightPolygon.vertexCoordinate(0);

//        MissionItem* item = new MissionItem(seqNum++,
//                                            MAV_CMD_NAV_WAYPOINT,
//                                            _altitudeRelative ? MAV_FRAME_GLOBAL_RELATIVE_ALT : MAV_FRAME_GLOBAL,
//                                            0,                                          // No hold time
//                                            0.0,                                        // No acceptance radius specified
//                                            0.0,                                        // Pass through waypoint
//                                            std::numeric_limits<double>::quiet_NaN(),   // Yaw unchanged
//                                            vertexCoord.latitude(),
//                                            vertexCoord.longitude(),
//                                            layerAltitude,
//                                            true,                                       // autoContinue
//                                            false,                                      // isCurrentItem
//                                            missionItemParent);
//        items.append(item);

//        item = new MissionItem(seqNum++,
//                               MAV_CMD_DO_SET_CAM_TRIGG_DIST,
//                               MAV_FRAME_MISSION,
//                               0,           // stop triggering
//                               0,           // shutter integration (ignore)
//                               0,           // trigger immediately when starting
//                               0, 0, 0, 0,  // param 4-7 unused
//                               true,        // autoContinue
//                               false,       // isCurrentItem
//                               missionItemParent);
//        items.append(item);
//    }
}

int CircleScanComplexItem::cameraShots(void) const
{
    return true /*_triggerCamera()*/ ? _cameraShots : 0;
}

void CircleScanComplexItem::setMissionFlightStatus(MissionController::MissionFlightStatus_t& missionFlightStatus)
{
    ComplexMissionItem::setMissionFlightStatus(missionFlightStatus);
    if (!qFuzzyCompare(_cruiseSpeed, missionFlightStatus.vehicleSpeed)) {
        _cruiseSpeed = missionFlightStatus.vehicleSpeed;
        emit timeBetweenShotsChanged();
    }
}

void CircleScanComplexItem::_setDirty(void)
{
    setDirty(true);
}

void CircleScanComplexItem::applyNewAltitude(double newAltitude)
{
    _altitudeFact.setRawValue(newAltitude);
}

void CircleScanComplexItem::_polygonDirtyChanged(bool dirty)
{
    if (dirty) {
        setDirty(true);
    }
}

double CircleScanComplexItem::timeBetweenShots(void)
{
    return _cruiseSpeed == 0 ? 0 : _cameraCalc.adjustedFootprintSide()->rawValue().toDouble() / _cruiseSpeed;
}

QGeoCoordinate CircleScanComplexItem::coordinate(void) const
{
    if (_flightPolygon.count() > 0) {
//        int entryVertex = qMax(qMin(_entryVertex, _flightPolygon.count() - 1), 0);
        return _flightPolygon.vertexCoordinate(_flightPolygon.count() - 1);
    } else {
        return QGeoCoordinate();
    }
}

QGeoCoordinate CircleScanComplexItem::exitCoordinate(void) const
{
    return coordinate();
}

void CircleScanComplexItem::_updateCoordinateAltitudes(void)
{
    emit coordinateChanged(coordinate());
    emit exitCoordinateChanged(exitCoordinate());
}

void CircleScanComplexItem::rotateEntryPoint(void)
{
    _entryVertex++;
    if (_entryVertex >= _flightPolygon.count()) {
        _entryVertex = 0;
    }
    emit coordinateChanged(coordinate());
    emit exitCoordinateChanged(exitCoordinate());
}

void CircleScanComplexItem::_rebuildFlightPolygon(void)
{
//    _flightPolygon = _structurePolygon;
    //_cameraCalc.distanceToSurface()->rawValue().toDouble()
    QGCMapPolygon tempPolygon = _structurePolygon;
    tempPolygon.offset(0);
    _flightPolygon = tempPolygon;
//    qCWarning(CircleScanComplexItemLog) << "CircleScanComplexItem count " << tempPolygon.count();
    if(tempPolygon.count() > 4) {
        _radius = (tempPolygon.vertexCoordinate(0)).distanceTo(tempPolygon.vertexCoordinate(4)) / 2;
    }
    if(_layersFact.rawValue().toInt() > 1) {
        _flightPolygon.appendVertex(tempPolygon.vertexCoordinate(0));
        for(int layer=1; layer<_layersFact.rawValue().toInt(); layer++) {
            tempPolygon.offset(_radius);
            for(int i=0; i<tempPolygon.count(); i++) {
                _flightPolygon.appendVertex(tempPolygon.vertexCoordinate(i));
            }
            _flightPolygon.appendVertex(tempPolygon.vertexCoordinate(0));
        }
    }
}

void CircleScanComplexItem::_recalcCameraShots(void)
{
    double triggerDistance = _cameraCalc.adjustedFootprintSide()->rawValue().toDouble();
    if (triggerDistance == 0) {
        _setCameraShots(0);
        return;
    }

    if (_flightPolygon.count() < 3) {
        _setCameraShots(0);
        return;
    }

    // Determine the distance for each polygon traverse
    double distance = 0;
    for (int i=0; i<_flightPolygon.count(); i++) {
        QGeoCoordinate coord1 = _flightPolygon.vertexCoordinate(i);
        QGeoCoordinate coord2 = _flightPolygon.vertexCoordinate(i + 1 == _flightPolygon.count() ? 0 : i + 1);
        distance += coord1.distanceTo(coord2);
    }
    if (distance == 0.0) {
        _setCameraShots(0);
        return;
    }

    int cameraShots = static_cast<int>(distance / triggerDistance);
    _setCameraShots(cameraShots * _layersFact.rawValue().toInt());
}

void CircleScanComplexItem::setAltitudeRelative(bool altitudeRelative)
{
    if (altitudeRelative != _altitudeRelative) {
        _altitudeRelative = altitudeRelative;
        emit altitudeRelativeChanged(altitudeRelative);
    }
}

void CircleScanComplexItem::_recalcLayerInfo(void)
{
    // Structure height is calculated from layer count, layer height.
    _structureHeightFact.setSendValueChangedSignals(false);
    _structureHeightFact.setRawValue(_layersFact.rawValue().toInt() * _cameraCalc.adjustedFootprintFrontal()->rawValue().toDouble());
    _structureHeightFact.clearDeferredValueChangeSignal();
    _structureHeightFact.setSendValueChangedSignals(true);
}

void CircleScanComplexItem::_updateGimbalPitch(void)
{
    if (!_cameraCalc.isManualCamera()) {
        _gimbalPitchFact.setRawValue(0);
    }
}
