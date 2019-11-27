#ifndef TEST2_H
#define TEST2_H

#include <QObject>

class test2 : public QObject
{
    Q_OBJECT
public:
    explicit test2(QObject *parent = nullptr);

signals:

public slots:
};

#endif // TEST2_H
