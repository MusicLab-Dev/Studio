/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio class
 */

// #include <Audio/PluginTable.hpp>

#include <QFont>
#include <QFile>
#include <QFontDatabase>

#include "AudioAPI.hpp"
#include "Application.hpp"
#include "ThemeManager.hpp"
#include "Studio.hpp"
#include "SettingsListModel.hpp"
#include "SettingsListModelProxy.hpp"

// #include "BoardManager.hpp"

void Studio::InitResources(void)
{
    Audio::PluginTable::Init();
    Audio::Device::InitDriver();

    qmlRegisterSingletonInstance<AudioAPI>("AudioAPI", 1, 0, "AudioAPI", AudioAPI::Instantiate());
    qmlRegisterUncreatableType<BeatRange>("AudioAPI", 1, 0, "BeatRange", "Cannot construct BeatRange");
    qmlRegisterUncreatableType<Note>("AudioAPI", 1, 0, "Note", "Cannot construct Note");
    qmlRegisterUncreatableType<NoteEvent>("AudioAPI", 1, 0, "NoteEvent", "Cannot construct NoteEvent");
    qmlRegisterUncreatableType<GPoint>("AudioAPI", 1, 0, "Point", "Cannot construct Point");
    qmlRegisterType<ThemeManager>("ThemeManager", 1, 0, "ThemeManager");
    qmlRegisterType<Application>("Application", 1, 0, "Application");
    qmlRegisterUncreatableType<Project>("Project", 1, 0, "Project", "Cannot construct Project");
    qmlRegisterUncreatableType<NodeModel>("NodeModel", 1, 0, "NodeModel", "Cannot construct NodeModel");
    qmlRegisterUncreatableType<PartitionsModel>("PartitionsModel", 1, 0, "PartitionsModel", "Cannot construct PartitionsModel");
    qmlRegisterUncreatableType<PartitionModel>("PartitionModel", 1, 0, "PartitionModel", "Cannot construct PartitionModel");
    qmlRegisterUncreatableType<ControlsModel>("ControlsModel", 1, 0, "ControlsModel", "Cannot construct ControlsModel");
    qmlRegisterUncreatableType<ControlModel>("ControlModel", 1, 0, "ControlModel", "Cannot construct ControlModel");
    qmlRegisterUncreatableType<AutomationModel>("AutomationModel", 1, 0, "AutomationModel", "Cannot construct AutomationModel");
    qmlRegisterUncreatableType<InstancesModel>("InstancesModel", 1, 0, "InstancesModel", "Cannot construct InstancesModel");
    // qmlRegisterType<BoardManager>("BoardManager", 1, 0, "BoardManager");

    Q_INIT_RESOURCE(Resources);
    Q_INIT_RESOURCE(Main);
    Q_INIT_RESOURCE(Default);
    Q_INIT_RESOURCE(ModulesView);
    Q_INIT_RESOURCE(SequencerView);
    Q_INIT_RESOURCE(Common);
    Q_INIT_RESOURCE(PlaylistView);
    Q_INIT_RESOURCE(EmptyView);
    Q_INIT_RESOURCE(BoardView);

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
    Q_CLEANUP_RESOURCE(ModulesView);
    Q_CLEANUP_RESOURCE(SequencerView);
    Q_CLEANUP_RESOURCE(Common);
    Q_CLEANUP_RESOURCE(PlaylistView);
    Q_CLEANUP_RESOURCE(EmptyView);
    Q_CLEANUP_RESOURCE(BoardView);

    /** Modules **/
    Q_CLEANUP_RESOURCE(Plugins);
    Q_CLEANUP_RESOURCE(Workspaces);
    Q_CLEANUP_RESOURCE(Settings);
    Q_CLEANUP_RESOURCE(Board);

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
