#include "sqlquerymodel.h"
#include <QSqlField>
#include <QSqlRecord>
#include <QSqlField>
#include<QSqlError>
#include<QDebug>
#include<QSqlQuery>


SqlQueryModel::SqlQueryModel(QObject *parent) :
    QSqlQueryModel(parent)
{

}

SqlQueryModel::~SqlQueryModel(){

    if(_db.isOpen())
    {
        _db.close();
    }
}

bool SqlQueryModel::setDatabase(const QString &database){


    _db = QSqlDatabase::addDatabase("QMYSQL", "test");
    _db.setHostName("localhost");
    _db.setUserName("root");
    _db.setPassword("123456");
    if (_db.isOpen()) {
        _db.close();
        this->clear();
    }

    _db.setDatabaseName(database);

    if (!_db.open()) {
        qWarning() << "MYSQLModel::setDatabase() -" << _db.lastError().text();
        return false;
    }

    return true;

}

bool SqlQueryModel::setQuery(const QString &query) {
        QSqlQueryModel::setQuery(query, _db);
        if (this->query().record().isEmpty()) {
         qWarning() << "SQLiteModel::setQuery() -" << this->query().lastError();
            return false;
        }
        return true;
}

QHash<int, QByteArray> SqlQueryModel::roleNames() const {

        QHash<int, QByteArray> roles;
        for ( int i = 0; i < this->record().count(); i++) {
            roles[Qt::UserRole + i + 1] = this->record().fieldName(i).toLocal8Bit();
        }
        return roles;
}

QVariant SqlQueryModel::data(const QModelIndex &index, int role) const {
        QVariant value = QSqlQueryModel::data(index, role);

        if (role < Qt::UserRole)
            value = QSqlQueryModel::data(index, role);
        else {
            int row = index.row();
            int col = role - Qt::UserRole - 1;

            QModelIndex modelIndex = this->index(row, col);

            value = QSqlQueryModel::data(modelIndex, Qt::DisplayRole);
        }

        return value;
}

void SqlQueryModel::eraseAll()
{
    QString name;
    {
        name = QSqlDatabase::database().connectionName();
    }//超出作用域，隐含对象QSqlDatabase::database()被删除。
    QSqlDatabase::removeDatabase(name);

    this->clear();

}

QList<QVariant> SqlQueryModel::getData(const int &row)
{
    QList<QVariant> value;
    for(int i=0;i<record().count();i++)
    {
        QModelIndex modelIndex = this->index(row, i);
        value <<QSqlQueryModel::data(modelIndex, Qt::DisplayRole);
    }
    return value;
}

QVariant SqlQueryModel::getIndex(const int &row,int role)
{
    QModelIndex modelIndex = this->index(row, role);
    QVariant value =QSqlQueryModel::data(modelIndex, Qt::DisplayRole);
    return value;
}


int SqlQueryModel::getLastQuery(QString str){


    QSqlQuery query(_db);
    QString queryFirstStr= QString ("select * from happytest7  where identification = %1 order by id  limit 0,1").arg(str);
    query.exec(queryFirstStr);
    int firststr=0;
    int laststr=0;
    if(!query.exec())
    {
        qDebug()<<"Error: invalid getlast query";
    }

    while (query.next()){
        firststr=query.value("id").toInt();
    }

    QString queryLastStr=QString("select * from happytest7  where identification = %1 order by id desc limit 0,1").arg(str) ;
    query.exec(queryLastStr);
    while (query.next()) {
        laststr=query.value("id").toInt();
    }
    int count = laststr-firststr;
    return count;

}

void SqlQueryModel::test()
{



    qDebug()<<"111";
}
