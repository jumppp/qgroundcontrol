﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include "ComplexMissionItem.h"
#include "MissionItem.h"
#include "SettingsFact.h"
#include "QGCLoggingCategory.h"
#include "QGCMapPolygon.h"
#include "CameraCalc.h"

Q_DECLARE_LOGGING_CATEGORY(CircleScanComplexItemLog)

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

class CircleScanComplexItem : public ComplexMissionItem
{
    Q_OBJECT

public:
    /// @param vehicle Vehicle which this is being contructed for
    /// @param flyView true: Created for use in the Fly View, false: Created for use in the Plan View
    /// @param kmlOrSHPFile Polygon comes from this file, empty for default polygon
    CircleScanComplexItem(Vehicle* vehicle, bool flyView, const QString& kmlOrSHPFile, QObject* parent);

    Q_PROPERTY(CameraCalc*      cameraCalc                  READ cameraCalc                                                 CONSTANT)
    Q_PROPERTY(Fact*            altitude                    READ altitude                                                   CONSTANT)
    Q_PROPERTY(Fact*            structureHeight             READ structureHeight                                            CONSTANT)
    Q_PROPERTY(Fact*            layers                      READ layers                                                     CONSTANT)
    Q_PROPERTY(Fact*            loiterTime                  READ loiterTime                                                 CONSTANT)
    Q_PROPERTY(Fact*            circleRadius                READ circleRadius                                               CONSTANT)
    Q_PROPERTY(Fact*            gimbalPitch                 READ gimbalPitch                                                CONSTANT)
    Q_PROPERTY(bool             altitudeRelative            READ altitudeRelative           WRITE setAltitudeRelative       NOTIFY altitudeRelativeChanged)
    Q_PROPERTY(int              cameraShots                 READ cameraShots                                                NOTIFY cameraShotsChanged)
    Q_PROPERTY(double           timeBetweenShots            READ timeBetweenShots                                           NOTIFY timeBetweenShotsChanged)
    Q_PROPERTY(QGCMapPolygon*   structurePolygon            READ structurePolygon                                           CONSTANT)
    Q_PROPERTY(QGCMapPolygon*   flightPolygon               READ flightPolygon                                              CONSTANT)

    CameraCalc* cameraCalc  (void) { return &_cameraCalc; }
    Fact* altitude          (void) { return &_altitudeFact; }
    Fact* structureHeight   (void) { return &_structureHeightFact; }
    Fact* layers            (void) { return &_layersFact; }
    Fact* loiterTime        (void) {return  &_loiterTimeFact;}
    Fact* circleRadius      (void) {return  &_circleRadiusFact;}
    Fact* gimbalPitch       (void) { return &_gimbalPitchFact; }

    bool            altitudeRelative        (void) const { return _altitudeRelative; }
    int             cameraShots             (void) const;
    double          timeBetweenShots        (void);
    QGCMapPolygon*  structurePolygon        (void) { return &_structurePolygon; }
    QGCMapPolygon*  flightPolygon           (void) { return &_flightPolygon; }

    void setAltitudeRelative        (bool altitudeRelative);

    Q_INVOKABLE void rotateEntryPoint(void);

    // Overrides from ComplexMissionItem

    double          complexDistance     (void) const final { return _scanDistance; }
    int             lastSequenceNumber  (void) const final;
    bool            load                (const QJsonObject& complexObject, int sequenceNumber, QString& errorString) final;
    double          greatestDistanceTo  (const QGeoCoordinate &other) const final;
    QString         mapVisualQML        (void) const final { return QStringLiteral("CircleScanMapVisual.qml"); }

    // Overrides from VisualMissionItem

    bool            dirty                   (void) const final { return _dirty; }
    bool            isSimpleItem            (void) const final { return false; }
    bool            isStandaloneCoordinate  (void) const final { return false; }
    bool            specifiesCoordinate     (void) const final;
    bool            specifiesAltitudeOnly   (void) const final { return false; }
    QString         commandDescription      (void) const final { return tr("Circle Scan"); }
    QString         commandName             (void) const final { return tr("Circle Scan"); }
    QString         abbreviation            (void) const final { return "S"; }
    QGeoCoordinate  coordinate              (void) const final;
    QGeoCoordinate  exitCoordinate          (void) const final;
    int             sequenceNumber          (void) const final { return _sequenceNumber; }
    double          specifiedFlightSpeed    (void) final { return std::numeric_limits<double>::quiet_NaN(); }
    double          specifiedGimbalYaw      (void) final { return std::numeric_limits<double>::quiet_NaN(); }
    double          specifiedGimbalPitch    (void) final { return std::numeric_limits<double>::quiet_NaN(); }
    void            appendMissionItems      (QList<MissionItem*>& items, QObject* missionItemParent) final;
    void            setMissionFlightStatus  (MissionController::MissionFlightStatus_t& missionFlightStatus) final;
    void            applyNewAltitude        (double newAltitude) final;
    double          additionalTimeDelay     (void) const final { return 0; }

    bool coordinateHasRelativeAltitude      (void) const final { return _altitudeRelative; }
    bool exitCoordinateHasRelativeAltitude  (void) const final { return _altitudeRelative; }
    bool exitCoordinateSameAsEntry          (void) const final { return true; }

    void setDirty           (bool dirty) final;
    void setCoordinate      (const QGeoCoordinate& coordinate) final { Q_UNUSED(coordinate); }
    void setSequenceNumber  (int sequenceNumber) final;
    void save               (QJsonArray&  missionItems) final;

    static const char* jsonComplexItemTypeValue;

    static const char* settingsGroup;
    static const char* altitudeName;
    static const char* structureHeightName;
    static const char* layersName;
    static const char* loiterTimeName;
    static const char* circleRadiusName;
    static const char* gimbalPitchName;

signals:
    void cameraShotsChanged             (int cameraShots);
    void timeBetweenShotsChanged        (void);
    void altitudeRelativeChanged        (bool altitudeRelative);

private slots:
    void _setDirty(void);
    void _polygonDirtyChanged       (bool dirty);
    void _flightPathChanged         (void);
    void _clearInternal             (void);
    void _updateCoordinateAltitudes (void);
    void _rebuildFlightPolygon      (void);
    void _recalcCameraShots         (void);
    void _recalcLayerInfo           (void);
    void _updateLastSequenceNumber  (void);
    void _updateGimbalPitch         (void);

private:
    void _setExitCoordinate(const QGeoCoordinate& coordinate);
    void _setScanDistance(double scanDistance);
    void _setCameraShots(int cameraShots);
    double _triggerDistance(void) const;

    QMap<QString, FactMetaData*> _metaDataMap;

    int             _sequenceNumber;
    bool            _dirty;
    QGCMapPolygon   _structurePolygon;
    QGCMapPolygon   _flightPolygon;
    bool            _altitudeRelative;
    int             _entryVertex;       // Polygon vertext which is used as the mission entry point

    bool            _ignoreRecalc;
    double          _scanDistance;
    double          _radius;
    int             _cameraShots;
    double          _timeBetweenShots;
    double          _cruiseSpeed;
    CameraCalc      _cameraCalc;


    SettingsFact    _altitudeFact;
    SettingsFact    _structureHeightFact;
    SettingsFact    _layersFact;
    SettingsFact    _loiterTimeFact;
    SettingsFact    _circleRadiusFact;
    SettingsFact    _gimbalPitchFact;

    static const char* _jsonCameraCalcKey;
    static const char* _jsonAltitudeRelativeKey;

    friend class CircleScanComplexItemTest;
};