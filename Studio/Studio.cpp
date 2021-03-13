/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio class
 */

// #include <Audio/PluginTable.hpp>

#include "ThemeManager.hpp"
#include "Application.hpp"

#include "Studio.hpp"

void Studio::InitResources(void)
{
    qmlRegisterType<ThemeManager>("ThemeManager", 1, 0, "ThemeManager");
    qmlRegisterType<Application>("Application", 1, 0, "Application");
    qmlRegisterUncreatableType<Project>("Project", 1, 0, "Project", "Cannot construct Project");
    qmlRegisterUncreatableType<NodeModel>("NodeModel", 1, 0, "NodeModel", "Cannot construct NodeModel");
    qmlRegisterUncreatableType<PartitionsModel>("PartitionsModel", 1, 0, "PartitionsModel", "Cannot construct PartitionsModel");
    qmlRegisterUncreatableType<PartitionModel>("PartitionModel", 1, 0, "PartitionModel", "Cannot construct PartitionModel");
    qmlRegisterUncreatableType<ControlsModel>("ControlsModel", 1, 0, "ControlsModel", "Cannot construct ControlsModel");
    qmlRegisterUncreatableType<AutomationModel>("AutomationModel", 1, 0, "AutomationModel", "Cannot construct AutomationModel");
    qmlRegisterUncreatableType<InstancesModel>("InstancesModel", 1, 0, "InstancesModel", "Cannot construct InstancesModel");
    Audio::PluginTable::Init();
    Audio::Device::InitDriver();
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
    Audio::Device::ReleaseDriver();
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
