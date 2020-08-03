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
#include<QSqlTableModel>
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
    QSqlDatabase::removeDatabase(dbName);
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


//从sqlmodel中获取数据，写入csv函数
void Database_Env::ReadDataFromSqlWriteToCSV(const QString &tableName,const QString &csvFileName,QString identification){

    QSqlTableModel *exportModel = new QSqlTableModel(nullptr,db);
    exportModel->setTable(tableName);
    exportModel->setEditStrategy(QSqlTableModel::OnManualSubmit);
    QString sql = QString("%1.identification= %2").arg(tableName).arg(identification);
    exportModel->setFilter(sql);
    exportModel->select();
    if(!exportModel->select()){
        qDebug()<<exportModel->lastError();
    }
    QStringList strList;//记录数据库中的一行报警数据
    QString strString;
    const QString FILE_PATH(csvFileName);

    QFile csvFile(FILE_PATH);
    if (csvFile.open(QIODevice::ReadWrite))
    {
        QString title = "ID,时间1,时间2,标志,经度,纬度,高度,温度,湿度,压力,pm2.5,pm10,S02,NO2,C0,O3\n";
        csvFile.write(title.toLocal8Bit());
        qDebug()<<"open file ok";
        for (int i=0;i<exportModel->rowCount();i++)
        {
            for(int j=0;j<exportModel->columnCount();j++)
            {
                strList.insert(j,exportModel->data(exportModel->index(i,j)).toString());//把每一行的每一列数据读取到strList中
            }
            strString = strList.join(", ")+"\n";//给两个列数据之前加“,”号，一行数据末尾加回车
            strList.clear();//记录一行数据后清空，再记下一行数据
            csvFile.write(strString.toLocal8Bit());//使用方法：转换为Utf8格式后在windows下的excel打开是乱码,可先用notepad++打开并转码为unicode，再次用excel打开即可。
            //qDebug()<<strString.toUtf8();
        }
        csvFile.close();
    }
    delete exportModel;
}

//根据identification导出文件
void Database_Env::exportCsv(QString identification){

     QString desktop_path = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
     QString filepath = desktop_path+"/"+getMissonStartTime()+".csv";
     qDebug()<< "filepath:" << filepath;
     connect_Database();
     ReadDataFromSqlWriteToCSV(tableName6,filepath,identification);

     QMessageBox::information(nullptr,"Success","file export succeed");
     disconnect_Database();
     qDebug()<<db.lastError();

}
