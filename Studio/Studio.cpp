/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio class
 */


#include "QDebug"
#include "InstancesModel.hpp"
#include "Studio.hpp"

Studio::Studio(int argc, char *argv[])
    : QGuiApplication(argc, argv)
{
    const QUrl url(QStringLiteral("qrc:/Main.qml"));

    QObject::connect(&_engine, &QQmlApplicationEngine::objectCreated, this,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
    Qt::QueuedConnection);

    _engine.load(url);
}

int Studio::run(void)
{
    qDebug("ok");
    return QGuiApplication::exec();
}
