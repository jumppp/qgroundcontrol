#include "database_env.h"
#include "QGCApplication.h"
#include "database_env.h"
#include <QSqlDatabase>
#include <QDebug>
#include <QMessageBox>
#include <QErrorMessage>
#include <QSqlError>
#include <QMessageBox>
#include <QTimer>
#include <Vehicle.h>
#include <QSqlDatabase>
#include <QSqlQuery>
#include<QSqlQueryModel>
#include<QDateTime>
#include <QSqlError>
#include <QThread>
#include "Vehicle.h"



Database_Env::Database_Env(QObject *parent) : QObject(parent),_dbopen(false)
{


}
Database_Env::~Database_Env(){

    if(db.isOpen())
    {
        db.close();
    }
    timer->stop();

}

bool Database_Env::connect_Database()
{

        if (QSqlDatabase::contains(dbName)) {
            db = QSqlDatabase::database(dbName);
        } else {
            db = QSqlDatabase::addDatabase("QMYSQL", dbName);
        }
        db.setDatabaseName(dbName);
        db.setHostName("localhost");
        db.setUserName("root");
        db.setPassword("123456");
        if (db.isOpen()) {
            db.close();
        }
        _dbopen = db.open();
        if (_dbopen)
        {
            qDebug()<<"databese open succeed";
            QMessageBox::information(nullptr,"Success","databese open succeed");
            timer_Record();
            return true;
        }
        else{
            qDebug()<<"databese open failed";
            QMessageBox::warning(nullptr,"ERROR","databese open failed");
            qDebug()<<db.lastError().text();
            return false;
        }
}

bool Database_Env::disconnect_Database()
{
    db.close();
    timer->stop();
    if(_dbopen)
    {
        QMessageBox::warning(nullptr,"Error","database close failed");
        return false;
    }
    else
    {
        QMessageBox::information(nullptr,"Success","database close succeed");
        return true;
    }

}

void Database_Env::timer_Record()
{

    QSqlQuery query(db);
    QStringList table = db.tables();
    if(table.contains(tableName6))
    {
         query.prepare(creatTable6);
         qDebug()<<"table already exsists";
    }
    else {
        query.prepare(creatTable6);
        query.exec(creatTable6);
        if(query.exec())
        {
            qDebug()<<"new table created success";
        }
        else
        {
            qDebug()<<"table created failed";
            qDebug()<<db.lastError().text();
        }
    }
    timer = new QTimer();
    timer->setInterval(msecInterval);
    qDebug()<<"timer 11111";
    connect(timer,SIGNAL(timeout()),this,SLOT(startSql()));
    timer->start();
    strStarTime=getMissonStartTime();

}

QString Database_Env::getMissonStartTime()
{
    QDateTime cur_date_time = QDateTime::currentDateTime();
    QString cur_time = cur_date_time.toString("yyyyMMddhhmmss");
    return cur_time;
}

void Database_Env::startSql()
{
    QSqlQuery query(db);
    QDateTime cur_date_time = QDateTime::currentDateTime();
    QString cur_time = cur_date_time.toString("yyyy-MM-dd hh:mm:ss");
    QString cur_time_time = cur_date_time.toString("hh:mm:ss");
    qDebug()<<cur_time;

    double longitude = qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->gpsFactGroup()->getFact("lon")->rawValue().toDouble();
    double latitude = qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->gpsFactGroup()->getFact("lat")->rawValue().toDouble();
    double altitude = qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->altitudeRelative()->rawValue().toDouble();
    float gastempreture = qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->gasSensorFactGroup()->getFact("gasTemperature")->rawValue().toInt();
    float temperature = gastempreture/100;
    int humidity = qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->gasSensorFactGroup()->getFact("humidity")->rawValue().toInt();
    int gaspressure = qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->gasSensorFactGroup()->getFact("gasPressure")->rawValue().toInt();
    int pm25 = qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->gasSensorFactGroup()->getFact("pm25")->rawValue().toInt();
    int pm10 = qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->gasSensorFactGroup()->getFact("pm10")->rawValue().toInt();
    int SO2 = qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->gasSensorFactGroup()->getFact("so2")->rawValue().toInt();
    int NO2 = qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->gasSensorFactGroup()->getFact("no2")->rawValue().toInt();
    float CO = qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->gasSensorFactGroup()->getFact("co")->rawValue().toInt();
    float COO=CO/100;
    int O3 = qgcApp()->toolbox()->multiVehicleManager()->activeVehicle()->gasSensorFactGroup()->getFact("o3")->rawValue().toInt();
    qDebug()<<strStarTime;
    query.prepare(inserttoTable6);
    query.bindValue(":t_time",cur_time);
    query.bindValue(":t_time_time",cur_time_time);
    query.bindValue(":identification",strStarTime);
    //query.bindValue(":longitude",longitude);
    //query.bindValue(":latitude",latitude);
    //query.bindValue(":altitude",altitude);
    query.bindValue(":tempreture",temperature);
    query.bindValue(":humidity",humidity);
    query.bindValue(":presure",gaspressure);
    query.bindValue(":pm2_5",pm25);
    query.bindValue(":pm10",pm10);
    query.bindValue(":SO2",SO2);
    query.bindValue(":NO2",NO2);
    query.bindValue(":CO",COO);
    query.bindValue(":O3",O3);

    bool success = query.exec();
    if(success)
    {
        qDebug()<<"insert success";
    }
    else
    {
        qDebug()<<"insert failed";
        qDebug()<<db.lastError().text();
    }

    qDebug()<<"storing data";
}
