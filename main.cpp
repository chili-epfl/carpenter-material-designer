#include <QApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include "global.h"
#include <QDebug>
#include <QtQml>
#include "exporter.h"
int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    qDebug()<<tmpDir;
    if(!QDir(tmpDir).exists()){
        qDebug()<<"Creating tmp Path";
        QDir().mkpath(tmpDir);
    }
    if(!QDir(materialsDir).exists()){
        qDebug()<<"Creating materials Path";
        QDir().mkpath(materialsDir);
    }
    if(!QDir(uploadedDir).exists()){
        qDebug()<<"Creating uploaded Path";
        QDir().mkpath(uploadedDir);
    }

    qmlRegisterType<Exporter>("Exporter", 1, 0, "Exporter");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
