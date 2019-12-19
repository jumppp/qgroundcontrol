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
    Q_INVOKABLE void eraseAll();//擦除数据
    Q_INVOKABLE QList<QVariant> getData(const int &index);
    Q_INVOKABLE QVariant getIndex(const int &row,int role);//用于row role
    Q_INVOKABLE int getLastQuery(QString str); //用于获取一个model中identification的行数
    Q_INVOKABLE void test();

//    void setQuery(const QString &query, const QSqlDatabase &db = QSqlDatabase());
//    void setQuery(const QSqlQuery &query);

    Q_INVOKABLE QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;
private:
    QSqlDatabase _db;
    //static QString _connection();
};
#endif // SQLQUERYMODEL_H
