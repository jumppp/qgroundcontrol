/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "SectorScanComplexItem.h"
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

QGC_LOGGING_CATEGORY(SectorScanComplexItemLog, "SectorScanComplexItemLog")

const char* SectorScanComplexItem::settingsGroup =               "SectorScan";
const char* SectorScanComplexItem::sectorRadiusName =            "SectorRadius";
const char* SectorScanComplexItem::startAngleName =              "StartAngle";
const char* SectorScanComplexItem::flyAngleName =                "FlyAngle";
const char* SectorScanComplexItem::altitudeName =                "Altitude";
const char* SectorScanComplexItem::structureHeightName =         "StructureHeight";
const char* SectorScanComplexItem::layersName =                  "Layers";
const char* SectorScanComplexItem::gimbalPitchName =             "GimbalPitch";

const char* SectorScanComplexItem::jsonComplexItemTypeValue =    "SectorScan";
const char* SectorScanComplexItem::_jsonCameraCalcKey =          "CameraCalc";
const char* SectorScanComplexItem::_jsonAltitudeRelativeKey =    "altitudeRelative";

SectorScanComplexItem::SectorScanComplexItem(Vehicle* vehicle, bool flyView, const QString& kmlOrShpFile, QObject* parent)
    : ComplexMissionItem        (vehicle, flyView, parent)
    , _metaDataMap              (FactMetaData::createMapFromJsonFile(QStringLiteral(":/src/MissionManager/SectorScan.SettingsGroup.json"), this /* QObject parent */))
    , _sequenceNumber           (0)
    , _dirty                    (false)
    , _altitudeRelative         (true)
    , _entryVertex              (0)
    , _ignoreRecalc             (false)
    , _scanDistance             (0.0)
    , _radius                   (50.0)
    , _cameraShots              (0)
    , _cameraCalc               (vehicle, settingsGroup)
    , _sectorRadiusFact         (settingsGroup, _metaDataMap[sectorRadiusName])
    , _startAngleFact           (settingsGroup, _metaDataMap[startAngleName])
    , _flyAngleFact             (settingsGroup, _metaDataMap[flyAngleName])
    , _altitudeFact             (settingsGroup, _metaDataMap[altitudeName])
    , _structureHeightFact      (settingsGroup, _metaDataMap[structureHeightName])
    , _layersFact               (settingsGroup, _metaDataMap[layersName])
    , _gimbalPitchFact          (settingsGroup, _metaDataMap[gimbalPitchName])
{
    _editorQml = "qrc:/qml/SectorScanEditor.qml";

    _altitudeFact.setRawValue(qgcApp()->toolbox()->settingsManager()->appSettings()->defaultMissionItemAltitude()->rawValue());

    connect(&_sectorRadiusFact,   &Fact::valueChanged, this, &SectorScanComplexItem::_setDirty);
    connect(&_startAngleFact,   &Fact::valueChanged, this, &SectorScanComplexItem::_setDirty);
    connect(&_flyAngleFact,     &Fact::valueChanged, this, &SectorScanComplexItem::_setDirty);
    connect(&_altitudeFact,     &Fact::valueChanged, this, &SectorScanComplexItem::_setDirty);
    connect(&_layersFact,       &Fact::valueChanged, this, &SectorScanComplexItem::_setDirty);
    connect(&_gimbalPitchFact,  &Fact::valueChanged, this, &SectorScanComplexItem::_setDirty);

    connect(&_layersFact,                           &Fact::valueChanged,    this, &SectorScanComplexItem::_recalcLayerInfo);
    connect(&_structureHeightFact,                  &Fact::valueChanged,    this, &SectorScanComplexItem::_recalcLayerInfo);
    connect(_cameraCalc.adjustedFootprintFrontal(), &Fact::valueChanged,    this, &SectorScanComplexItem::_recalcLayerInfo);

    connect(this, &SectorScanComplexItem::altitudeRelativeChanged,       this, &SectorScanComplexItem::_setDirty);
    connect(this, &SectorScanComplexItem::altitudeRelativeChanged,       this, &SectorScanComplexItem::coordinateHasRelativeAltitudeChanged);
    connect(this, &SectorScanComplexItem::altitudeRelativeChanged,       this, &SectorScanComplexItem::exitCoordinateHasRelativeAltitudeChanged);

    connect(&_altitudeFact, &Fact::valueChanged, this, &SectorScanComplexItem::_updateCoordinateAltitudes);

    connect(&_structurePolygon, &QGCMapPolygon::dirtyChanged,   this, &SectorScanComplexItem::_polygonDirtyChanged);
    connect(&_structurePolygon, &QGCMapPolygon::pathChanged,    this, &SectorScanComplexItem::_structurePathChanged);
    connect(&_structurePolygon, &QGCMapPolygon::pathChanged,    this, &SectorScanComplexItem::_rebuildFlightPolygon);

    connect(&_sectorRadiusFact,   &Fact::valueChanged,            this, &SectorScanComplexItem::_rebuildFlightPolygon);
    connect(&_startAngleFact,   &Fact::valueChanged,            this, &SectorScanComplexItem::_rebuildFlightPolygon);
    connect(&_flyAngleFact,     &Fact::valueChanged,            this, &SectorScanComplexItem::_rebuildFlightPolygon);

    connect(&_structurePolygon, &QGCMapPolygon::countChanged,   this, &SectorScanComplexItem::_updateLastSequenceNumber);
    connect(&_layersFact,       &Fact::valueChanged,            this, &SectorScanComplexItem::_rebuildFlightPolygon);
    connect(&_layersFact,       &Fact::valueChanged,            this, &SectorScanComplexItem::_updateLastSequenceNumber);

    connect(&_flightPolygon,    &QGCMapPolygon::pathChanged,    this, &SectorScanComplexItem::_flightPathChanged);

    connect(_cameraCalc.distanceToSurface(),    &Fact::valueChanged,                this, &SectorScanComplexItem::_rebuildFlightPolygon);

    connect(&_flightPolygon,                        &QGCMapPolygon::pathChanged,    this, &SectorScanComplexItem::_recalcCameraShots);
    connect(_cameraCalc.adjustedFootprintSide(),    &Fact::valueChanged,            this, &SectorScanComplexItem::_recalcCameraShots);
    connect(&_layersFact,                           &Fact::valueChanged,            this, &SectorScanComplexItem::_recalcCameraShots);

    connect(&_cameraCalc, &CameraCalc::isManualCameraChanged, this, &SectorScanComplexItem::_updateGimbalPitch);

    _recalcLayerInfo();

    if (!kmlOrShpFile.isEmpty()) {
        _structurePolygon.loadKMLOrSHPFile(kmlOrShpFile);
        _structurePolygon.setDirty(false);
    }

    setDirty(false);
}

void SectorScanComplexItem::_setScanDistance(double scanDistance)
{
    if (!qFuzzyCompare(_scanDistance, scanDistance)) {
        _scanDistance = scanDistance;
        emit complexDistanceChanged();
    }
}

void SectorScanComplexItem::_setCameraShots(int cameraShots)
{
    if (_cameraShots != cameraShots) {
        _cameraShots = cameraShots;
        emit cameraShotsChanged(this->cameraShots());
    }
}

void SectorScanComplexItem::_clearInternal(void)
{
    setDirty(true);

    emit specifiesCoordinateChanged();
    emit lastSequenceNumberChanged(lastSequenceNumber());
}

void SectorScanComplexItem::_updateLastSequenceNumber(void)
{
    emit lastSequenceNumberChanged(lastSequenceNumber());
}

int SectorScanComplexItem::lastSequenceNumber(void) const
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

void SectorScanComplexItem::setDirty(bool dirty)
{
    if (_dirty != dirty) {
        _dirty = dirty;
        emit dirtyChanged(_dirty);
    }
}

void SectorScanComplexItem::save(QJsonArray&  missionItems)
{
    QJsonObject saveObject;

    // Header
    saveObject[JsonHelper::jsonVersionKey] =                    2;
    saveObject[VisualMissionItem::jsonTypeKey] =                VisualMissionItem::jsonTypeComplexItemValue;
    saveObject[ComplexMissionItem::jsonComplexItemTypeKey] =    jsonComplexItemTypeValue;

    saveObject[sectorRadiusName] =            _sectorRadiusFact.rawValue().toDouble();
    saveObject[startAngleName] =            _startAngleFact.rawValue().toDouble();
    saveObject[flyAngleName] =              _flyAngleFact.rawValue().toDouble();
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

void SectorScanComplexItem::setSequenceNumber(int sequenceNumber)
{
    if (_sequenceNumber != sequenceNumber) {
        _sequenceNumber = sequenceNumber;
        emit sequenceNumberChanged(sequenceNumber);
        emit lastSequenceNumberChanged(lastSequenceNumber());
    }
}

bool SectorScanComplexItem::load(const QJsonObject& complexObject, int sequenceNumber, QString& errorString)
{
    QList<JsonHelper::KeyValidateInfo> keyInfoList = {
        { JsonHelper::jsonVersionKey,                   QJsonValue::Double, true },
        { VisualMissionItem::jsonTypeKey,               QJsonValue::String, true },
        { ComplexMissionItem::jsonComplexItemTypeKey,   QJsonValue::String, true },
        { QGCMapPolygon::jsonPolygonKey,                QJsonValue::Array,  true },
        { sectorRadiusName,                               QJsonValue::Double, true },
        { startAngleName,                               QJsonValue::Double, true },
        { flyAngleName,                                 QJsonValue::Double, true },
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

    _startAngleFact.setRawValue     (complexObject[startAngleName].toDouble());
    _sectorRadiusFact.setRawValue     (complexObject[sectorRadiusName].toDouble());
    _flyAngleFact.setRawValue       (complexObject[flyAngleName].toDouble());
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

void SectorScanComplexItem::_flightPathChanged(void)
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

void SectorScanComplexItem::_structurePathChanged(void)
{
    // Calc bounding cube
    double north = 0.0;
    double south = 180.0;
    double east  = 0.0;
    double west  = 360.0;
    double bottom = 100000.;
    double top = 0.;
    QList<QGeoCoordinate> vertices = _structurePolygon.coordinateList();
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

double SectorScanComplexItem::greatestDistanceTo(const QGeoCoordinate &other) const
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

bool SectorScanComplexItem::specifiesCoordinate(void) const
{
    return _flightPolygon.count() > 2;
}

void SectorScanComplexItem::appendMissionItems(QList<MissionItem*>& items, QObject* missionItemParent)
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

int SectorScanComplexItem::cameraShots(void) const
{
    return true /*_triggerCamera()*/ ? _cameraShots : 0;
}

void SectorScanComplexItem::setMissionFlightStatus(MissionController::MissionFlightStatus_t& missionFlightStatus)
{
    ComplexMissionItem::setMissionFlightStatus(missionFlightStatus);
    if (!qFuzzyCompare(_cruiseSpeed, missionFlightStatus.vehicleSpeed)) {
        _cruiseSpeed = missionFlightStatus.vehicleSpeed;
        emit timeBetweenShotsChanged();
    }
}

void SectorScanComplexItem::_setDirty(void)
{
    setDirty(true);
}

void SectorScanComplexItem::applyNewAltitude(double newAltitude)
{
    _altitudeFact.setRawValue(newAltitude);
}

void SectorScanComplexItem::_polygonDirtyChanged(bool dirty)
{
    if (dirty) {
        setDirty(true);
    }
}

double SectorScanComplexItem::timeBetweenShots(void)
{
    return _cruiseSpeed == 0 ? 0 : _cameraCalc.adjustedFootprintSide()->rawValue().toDouble() / _cruiseSpeed;
}

QGeoCoordinate SectorScanComplexItem::coordinate(void) const
{
    if (_flightPolygon.count() > 0) {
//        int entryVertex = qMax(qMin(_entryVertex, _flightPolygon.count() - 1), 0);
        return _flightPolygon.vertexCoordinate(_flightPolygon.count() - 1);
    } else {
        return QGeoCoordinate();
    }
}

QGeoCoordinate SectorScanComplexItem::exitCoordinate(void) const
{
    return coordinate();
}

void SectorScanComplexItem::_updateCoordinateAltitudes(void)
{
    emit coordinateChanged(coordinate());
    emit exitCoordinateChanged(exitCoordinate());
}

void SectorScanComplexItem::rotateEntryPoint(void)
{
    _entryVertex++;
    if (_entryVertex >= _flightPolygon.count()) {
        _entryVertex = 0;
    }
    emit coordinateChanged(coordinate());
    emit exitCoordinateChanged(exitCoordinate());
}

void SectorScanComplexItem::_rebuildFlightPolygon(void)
{
    QGCMapPolygon tempPolygon = _structurePolygon;
    tempPolygon.offset(0);
    QGeoCoordinate center = tempPolygon.vertexCoordinate(0);
    tempPolygon.removeVertex(0);
    _flightPolygon = tempPolygon;
    int segments = 3;
    double startAngle = _startAngleFact.rawValue().toDouble();
    double angleIncrement = _flyAngleFact.rawValue().toDouble() / segments;
    double radius = _sectorRadiusFact.rawValue().toDouble();
    int totalLayers = _layersFact.rawValue().toInt();

//    if(totalLayers > 1) {
        for(int layer = 0; layer < totalLayers; layer++) {
            if(layer % 2 == 0) {
                for(int i = 0; i < (segments + 1); i++) {
                    QGeoCoordinate newCoord = center.atDistanceAndAzimuth(radius * (layer + 1), startAngle + angleIncrement * i);
                    _flightPolygon.appendVertex(newCoord);
                }
            }
            else {
                for(int i = segments ; i >= 0 ; i--) {
                    QGeoCoordinate newCoord = center.atDistanceAndAzimuth(radius * (layer + 1), startAngle + angleIncrement * i);
                    _flightPolygon.appendVertex(newCoord);
                }
            }
        }
        for(int j = 0; j < (segments + 1); j++) {
            _flightPolygon.removeVertex(0);
        }
//    }
}

void SectorScanComplexItem::_recalcCameraShots(void)
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

void SectorScanComplexItem::setAltitudeRelative(bool altitudeRelative)
{
    if (altitudeRelative != _altitudeRelative) {
        _altitudeRelative = altitudeRelative;
        emit altitudeRelativeChanged(altitudeRelative);
    }
}

void SectorScanComplexItem::_recalcLayerInfo(void)
{
    // Structure height is calculated from layer count, layer height.
    _structureHeightFact.setSendValueChangedSignals(false);
    _structureHeightFact.setRawValue(_layersFact.rawValue().toInt() * _cameraCalc.adjustedFootprintFrontal()->rawValue().toDouble());
    _structureHeightFact.clearDeferredValueChangeSignal();
    _structureHeightFact.setSendValueChangedSignals(true);
}

void SectorScanComplexItem::_updateGimbalPitch(void)
{
    if (!_cameraCalc.isManualCamera()) {
        _gimbalPitchFact.setRawValue(0);
    }
}
