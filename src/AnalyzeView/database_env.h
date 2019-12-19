#ifndef DATABASE_ENV_H
#define DATABASE_ENV_H

#include <QObject>
#include<QSqlDatabase>
#include <QTimer>
#include <QSqlQuery>

class Database_Env : public QObject
{
    Q_OBJECT
public:
    explicit Database_Env(QObject *parent = nullptr);
    ~Database_Env();
    QString dbName = "test";

    QString tableName = "happytest";
    QString creatTable ="create table happytest (id int primary key, name varchar(45) ,shijian DATETIME)";
    QString inserttoTable ="insert into happytest (id,name,shijian)  values(:id,:name,:shijian)";

    QString tableName1 = "happytest3";
    QString creatTable1 ="create table happytest3 (t_time DATETIME,t_time_time TIME,altitude DOUBLE)";
    QString inserttoTable1 ="insert into happytest3 (t_time,t_time_time,altitude) values(:t_time,:t_time_time,:altitude)";

    QString tableName6 = "happytest7";
    QString creatTable6 ="create table happytest7(id int not null auto_increment primary key,"
                         "t_time DATETIME,"
                         "t_time_time TIME,"
                         "identification varchar(20),"
                         "longitude decimal(10,7),"
                         "latitude decimal(10,7),"
                         "altitude float(5,2),"
                         "tempreture float,"
                         "humidity int,"
                         "presure int,"
                         "pm2_5 int,"
                         "pm10 int,"
                         "SO2 int,"
                         "NO2 int,"
                         "CO float,"
                         "O3 int)";
    QString inserttoTable6 ="insert into happytest7 (id,t_time,t_time_time,identification,longitude,latitude,altitude,tempreture,humidity,presure,pm2_5,pm10,SO2,NO2,CO,O3) "
                            "values(:id,:t_time,:t_time_time,:identification,:longitude,:latitude,:altitude,:tempreture,:humidity,:presure,:pm2_5,:pm10,:SO2,:NO2,:CO,:O3)";




    Q_INVOKABLE bool connect_Database();
    Q_INVOKABLE bool disconnect_Database();
    QTimer* timer;

signals:
private:
    void timer_Record();

    QString strStarTime;
    QString getMissonStartTime();
    QSqlDatabase  db;
    bool _dbopen;
    int msecInterval = 2000;

public slots:
    void startSql();

};


#endif // DATABASE_ENV_H
