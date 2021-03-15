/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio class
 */

#include <Audio/PluginTable.hpp>

#include "ThemeManager.hpp"
#include "Application.hpp"

#include "Studio.hpp"

void Studio::InitResources(void)
{
    qmlRegisterType<ThemeManager>("ThemeManager", 1, 0, "ThemeManager");
    qmlRegisterType<Application>("Application", 1, 0, "Application");
    // qmlRegisterUncreatableType<Scheduler>("Scheduler", 1, 0, "Scheduler", "Scheduler is not creatable");
    // qmlRegisterUncreatableType<Project>("Project", 1, 0, "Project", "Project is not creatable");
    // qmlRegisterType<NodeModel>("Project", 1, 0, "NodeModel");
    // qmlRegisterType<ControlsModel>("Project", 1, 0, "ControlsModel");
    // qmlRegisterType<ControlModel>("Project", 1, 0, "ControlModel");
    // qmlRegisterType<AutomationModel>("Project", 1, 0, "AutomationModel");
    // qmlRegisterType<PartitionsModel>("Project", 1, 0, "PartitionsModel");
    // qmlRegisterType<PartitionModel>("Project", 1, 0, "PartitionModel");
    // qmlRegisterType<InstancesModel>("Project", 1, 0, "InstancesModel");
    Audio::PluginTable::Init();
    Q_INIT_RESOURCE(Resources);
    Q_INIT_RESOURCE(Main);
    Q_INIT_RESOURCE(Default);
    Q_INIT_RESOURCE(ModulesView);
    Q_INIT_RESOURCE(SequencerView);
    Q_INIT_RESOURCE(Common);
    Q_INIT_RESOURCE(PlaylistView);
    Q_INIT_RESOURCE(EmptyView);
    Q_INIT_RESOURCE(BoardView);
}

void Studio::DestroyResources(void)
{
    Q_CLEANUP_RESOURCE(Resources);
    Q_CLEANUP_RESOURCE(Main);
    Q_CLEANUP_RESOURCE(Default);
    Q_CLEANUP_RESOURCE(ModulesView);
    Q_CLEANUP_RESOURCE(SequencerView);
    Q_CLEANUP_RESOURCE(Common);
    Q_CLEANUP_RESOURCE(PlaylistView);
    Q_CLEANUP_RESOURCE(EmptyView);
    Q_CLEANUP_RESOURCE(BoardView);
    Audio::PluginTable::Destroy();
}

static int DefaultArgc = 1;
static char DefaultArg[] = { 'S', 't', 'u', 'd', 'i', 'o', '\0' };
static char *DefaultArgv[] = { DefaultArg, nullptr };

Studio::Studio(void) : Studio(DefaultArgc, DefaultArgv)
{
}

Studio::Studio(int argc, char *argv[]) : QGuiApplication(argc, argv)
{
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
