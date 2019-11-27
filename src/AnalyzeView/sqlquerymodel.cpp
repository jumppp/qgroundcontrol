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
    _db = QSqlDatabase::addDatabase("QMYSQL", "test");
    _db.setHostName("localhost");
    _db.setUserName("root");
    _db.setPassword("123456");
}

SqlQueryModel::~SqlQueryModel(){

    if(_db.isOpen())
    {
        _db.close();
    }
}

bool SqlQueryModel::setDatabase(const QString &database){


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
