#ifndef SQLQUERYMODEL_H
#define SQLQUERYMODEL_H

#include <QObject>
#include <QSqlQueryModel>
#include <QSqlRecord>

class SqlQueryModel : public QSqlQueryModel
{
    Q_OBJECT

public:
    explicit SqlQueryModel(QObject *parent = nullptr);
    ~SqlQueryModel();
    Q_INVOKABLE bool setDatabase(const QString &database);
    Q_INVOKABLE bool setQuery(const QString &query);

//    void setQuery(const QString &query, const QSqlDatabase &db = QSqlDatabase());
//    void setQuery(const QSqlQuery &query);

    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;
private:
    QSqlDatabase _db;
    //static QString _connection();
};
#endif // SQLQUERYMODEL_H
