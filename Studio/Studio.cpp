/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio class
 */

#include <QFont>
#include <QFile>
#include <QFontDatabase>

#include "Studio.hpp"
#include "SettingsListModel.hpp"
#include "SettingsListModelProxy.hpp"

// #include "BoardManager.hpp"

void Studio::InitResources(void)
{
    // qmlRegisterType<BoardManager>("BoardManager", 1, 0, "BoardManager");
    Q_INIT_RESOURCE(Resources);
    Q_INIT_RESOURCE(Main);
    Q_INIT_RESOURCE(Default);
    Q_INIT_RESOURCE(Common);

    /** Modules **/
    Q_INIT_RESOURCE(Plugins);
    Q_INIT_RESOURCE(Workspaces);
    Q_INIT_RESOURCE(Settings);
    Q_INIT_RESOURCE(Board);
}

void Studio::DestroyResources(void)
{
    Q_CLEANUP_RESOURCE(Resources);
    Q_CLEANUP_RESOURCE(Main);
    Q_CLEANUP_RESOURCE(Default);
    Q_CLEANUP_RESOURCE(Common);

    /** Modules **/
    Q_CLEANUP_RESOURCE(Plugins);
    Q_CLEANUP_RESOURCE(Workspaces);
    Q_CLEANUP_RESOURCE(Settings);
    Q_CLEANUP_RESOURCE(Board);
}

static int DefaultArgc = 1;
static char DefaultArg[] = { 'S', 't', 'u', 'd', 'i', 'o', '\0' };
static char *DefaultArgv[] = { DefaultArg, nullptr };

Studio::Studio(void) : Studio(DefaultArgc, DefaultArgv)
{
}

Studio::Studio(int argc, char *argv[]) : QGuiApplication(argc, argv)
{
    qmlRegisterType<SettingsListModel>("SettingsListModel", 1, 0, "SettingsListModel");
    qmlRegisterType<SettingsListModelProxy>("SettingsListModel", 1, 0, "SettingsListModelProxy");

    const QUrl url(QStringLiteral("qrc:/Main/Main.qml"));

    QObject::connect(&_engine, &QQmlApplicationEngine::objectCreated, this,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
    Qt::QueuedConnection);

    _engine.load(url);
}

Studio::~Studio(void)
{
}

int Studio::run(void)
{
    return QGuiApplication::exec();
}
