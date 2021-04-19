/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio class
 */

// #include <Audio/PluginTable.hpp>

#include <QFont>
#include <QFile>
#include <QFontDatabase>
#include <QQuickStyle>

#include "AudioAPI.hpp"
#include "Application.hpp"
#include "PluginTableModel.hpp"
#include "PluginTableModelProxy.hpp"
#include "ThemeManager.hpp"
#include "Studio.hpp"
#include "SettingsListModel.hpp"
#include "SettingsListModelProxy.hpp"
#include "BoardManager.hpp"

// #include "BoardManager.hpp"

void Studio::InitResources(void)
{
    Audio::PluginTable::Init();
    Audio::Device::InitDriver();

    qRegisterMetaType<ParamID>("ParamID");
    qRegisterMetaType<ParamValue>("ParamValue");
    qRegisterMetaType<Beat>("Beat");
    qRegisterMetaType<Key>("Key");
    qRegisterMetaType<Velocity>("Velocity");
    qRegisterMetaType<Tuning>("Tuning");
    qRegisterMetaType<BPM>("BPM");
    qRegisterMetaType<NoteEvent::EventType>("NoteEvent::EventType");
    qRegisterMetaType<PluginTableModel::Tags>("PluginTableModel::Tags");

    qmlRegisterSingletonInstance<AudioAPI>("AudioAPI", 1, 0, "AudioAPI", AudioAPI::Instantiate());
    qmlRegisterUncreatableType<BeatRange>("AudioAPI", 1, 0, "BeatRange", "Cannot construct BeatRange");
    qmlRegisterUncreatableType<Note>("AudioAPI", 1, 0, "Note", "Cannot construct Note");
    qmlRegisterUncreatableType<NoteEvent>("AudioAPI", 1, 0, "NoteEvent", "Cannot construct NoteEvent");
    qmlRegisterUncreatableType<GPoint>("AudioAPI", 1, 0, "Point", "Cannot construct Point");
    qmlRegisterType<PluginTableModel>("PluginTableModel", 1, 0, "PluginTableModel");
    qmlRegisterType<PluginTableModelProxy>("PluginTableModel", 1, 0, "PluginTableModelProxy");
    qmlRegisterType<ThemeManager>("ThemeManager", 1, 0, "ThemeManager");
    qmlRegisterType<Application>("Application", 1, 0, "Application");
    qmlRegisterType<SettingsListModel>("SettingsListModel", 1, 0, "Application");
    qmlRegisterType<SettingsListModelProxy>("SettingsListModelProxy", 1, 0, "Application");
    qmlRegisterUncreatableType<Scheduler>("Scheduler", 1, 0, "Scheduler", "Cannot construct Scheduler");
    qmlRegisterUncreatableType<Project>("Project", 1, 0, "Project", "Cannot construct Project");
    qmlRegisterUncreatableType<NodeModel>("NodeModel", 1, 0, "NodeModel", "Cannot construct NodeModel");
    qmlRegisterUncreatableType<PartitionsModel>("PartitionsModel", 1, 0, "PartitionsModel", "Cannot construct PartitionsModel");
    qmlRegisterUncreatableType<PartitionModel>("PartitionModel", 1, 0, "PartitionModel", "Cannot construct PartitionModel");
    qmlRegisterUncreatableType<ControlsModel>("ControlsModel", 1, 0, "ControlsModel", "Cannot construct ControlsModel");
    qmlRegisterUncreatableType<ControlModel>("ControlModel", 1, 0, "ControlModel", "Cannot construct ControlModel");
    qmlRegisterUncreatableType<AutomationModel>("AutomationModel", 1, 0, "AutomationModel", "Cannot construct AutomationModel");
    qmlRegisterUncreatableType<InstancesModel>("InstancesModel", 1, 0, "InstancesModel", "Cannot construct InstancesModel");
    qmlRegisterType<BoardManager>("BoardManager", 1, 0, "BoardManager");
    qmlRegisterType<Board>("Board", 1, 0, "Board");

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

    Audio::PluginTable::Destroy();
    Audio::Device::ReleaseDriver();
}

static int DefaultArgc = 1;
static char DefaultArg[] = { 'S', 't', 'u', 'd', 'i', 'o', '\0' };
static char *DefaultArgv[] = { DefaultArg, nullptr };

Studio::Studio(void) : Studio(DefaultArgc, DefaultArgv)
{
    QQuickStyle::setStyle("Default");
}

Studio::Studio(int argc, char *argv[]) : QGuiApplication(argc, argv)
{
    qmlRegisterType<SettingsListModel>("SettingsListModel", 1, 0, "SettingsListModel");
    qmlRegisterType<SettingsListModelProxy>("SettingsListModel", 1, 0, "SettingsListModelProxy");

    /** DEBUG */
    //SettingsListModel list("test.json", "values.json", nullptr);
    //list.load();
    //list.saveValues();
    /* --- */

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

bool Studio::notify(QObject *receiver, QEvent *e)
{
    try {
        return QGuiApplication::notify(receiver, e);
    } catch (const std::exception &e) {
        qCritical() << e.what();
        return true;
    }
}