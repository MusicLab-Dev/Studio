/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio class
 */

// #include <Audio/PluginTable.hpp>

#include <QFont>
#include <QFile>
#include <QFontDatabase>
#include <QQuickStyle>
#include <QIcon>

#include "AudioAPI.hpp"
#include "Application.hpp"
#include "PluginTableModel.hpp"
#include "PluginTableModelProxy.hpp"
#include "ThemeManager.hpp"
#include "Studio.hpp"
#include "SettingsListModel.hpp"
#include "SettingsListModelProxy.hpp"
#include "BoardManager.hpp"
#include "EventDispatcher.hpp"
#include "DevicesModel.hpp"
#include "PartitionPreview.hpp"
#include "InstancesModelProxy.hpp"
#include "ActionsManager.hpp"
#include "NodeListModel.hpp"
#include "PluginModelProxy.hpp"

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
    qRegisterMetaType<MidiChannels>("MidiChannels");
    qRegisterMetaType<BlockSize>("BlockSize");
    qRegisterMetaType<SampleRate>("SampleRate");
    qRegisterMetaType<NoteEvent::EventType>("NoteEvent::EventType");
    qRegisterMetaType<GPoint::CurveRate>("GPoint::CurveRate");
    qRegisterMetaType<PluginModel::ParamType>("PluginModel::ParamType");
    qRegisterMetaType<PluginTableModel::Tags>("PluginTableModel::Tags");
    qRegisterMetaType<PluginTableModel::ExternalInputType>("PluginTableModel::ExternalInputType");
    qRegisterMetaType<AEventListener::EventTarget>("AEventListener::EventTarget");
    qRegisterMetaType<ActionNodeBase>("ActionNodeBase");
    qRegisterMetaType<ActionPartitionBase>("ActionPartitionBase");
    qRegisterMetaType<ActionNotesBase>("ActionNoteBase");
    qRegisterMetaType<ActionAddNotes>("ActionAddNotes");
    qRegisterMetaType<ActionMoveNotes>("ActionMoveNotes");
    qRegisterMetaType<ActionRemoveNotes>("ActionRemoveNotes");

    qmlRegisterSingletonInstance<AudioAPI>("AudioAPI", 1, 0, "AudioAPI", AudioAPI::Instantiate());
    qmlRegisterUncreatableType<BeatRange>("AudioAPI", 1, 0, "BeatRange", "Cannot construct BeatRange");
    qmlRegisterUncreatableType<Note>("AudioAPI", 1, 0, "Note", "Cannot construct Note");
    qmlRegisterUncreatableType<NoteEvent>("AudioAPI", 1, 0, "NoteEvent", "Cannot construct NoteEvent");
    qmlRegisterUncreatableType<GPoint>("AudioAPI", 1, 0, "Point", "Cannot construct Point");
    qmlRegisterUncreatableType<ControlEvent>("AudioAPI", 1, 0, "ControlEvent", "Cannot construct ControlEvent");
    qmlRegisterUncreatableType<PluginModel>("PluginModel", 1, 0, "PluginModel", "Cannot construct PluginModel");
    qmlRegisterType<PluginModelProxy>("PluginModelProxy", 1, 0, "PluginModelProxy");
    qmlRegisterType<PluginTableModel>("PluginTableModel", 1, 0, "PluginTableModel");
    qmlRegisterType<PluginTableModelProxy>("PluginTableModel", 1, 0, "PluginTableModelProxy");
    qmlRegisterType<ThemeManager>("ThemeManager", 1, 0, "ThemeManager");
    qmlRegisterType<Application>("Application", 1, 0, "Application");
    qmlRegisterType<SettingsListModel>("SettingsListModel", 1, 0, "SettingsListModel");
    qmlRegisterType<SettingsListModelProxy>("SettingsListModel", 1, 0, "SettingsListModelProxy");
    qmlRegisterUncreatableType<Scheduler>("Scheduler", 1, 0, "Scheduler", "Cannot construct Scheduler");
    qmlRegisterUncreatableType<Project>("Project", 1, 0, "Project", "Cannot construct Project");
    qmlRegisterUncreatableType<NodeModel>("NodeModel", 1, 0, "NodeModel", "Cannot construct NodeModel");
    qmlRegisterUncreatableType<PartitionsModel>("PartitionsModel", 1, 0, "PartitionsModel", "Cannot construct PartitionsModel");
    qmlRegisterUncreatableType<PartitionModel>("PartitionModel", 1, 0, "PartitionModel", "Cannot construct PartitionModel");
    qmlRegisterUncreatableType<ControlsModel>("ControlsModel", 1, 0, "ControlsModel", "Cannot construct ControlsModel");
    qmlRegisterUncreatableType<ControlModel>("ControlModel", 1, 0, "ControlModel", "Cannot construct ControlModel");
    qmlRegisterUncreatableType<AutomationModel>("AutomationModel", 1, 0, "AutomationModel", "Cannot construct AutomationModel");
    qmlRegisterUncreatableType<InstancesModel>("InstancesModel", 1, 0, "InstancesModel", "Cannot construct InstancesModel");
    qmlRegisterType<InstancesModelProxy>("InstancesModelProxy", 1, 0, "InstancesModelProxy");
    qmlRegisterType<BoardManager>("BoardManager", 1, 0, "BoardManager");
    qmlRegisterUncreatableType<Board>("Board", 1, 0, "Board", "Cannot constrict Board");
    qmlRegisterType<EventDispatcher>("EventDispatcher", 1, 0, "EventDispatcher");
    qmlRegisterUncreatableType<KeyboardEventListener>("KeyboardEventListener", 1, 0, "KeyboardEventListener", "Cannot construct KeyboardEventListener");
    qmlRegisterUncreatableType<BoardEventListener>("BoardEventListener", 1, 0, "BoardEventListener", "Cannot construct BoardEventListener");
    qmlRegisterType<DevicesModel>("DevicesModel", 1, 0, "DevicesModel");
    qmlRegisterType<PartitionPreview>("PartitionPreview", 1, 0, "PartitionPreview");
    qmlRegisterType<ActionsManager>("ActionsManager", 1, 0, "ActionsManager");
    qmlRegisterType<NodeListModel>("NodeListModel", 1, 0, "NodeListModel");

    Q_INIT_RESOURCE(Resources);
    Q_INIT_RESOURCE(Main);
    Q_INIT_RESOURCE(Default);
    Q_INIT_RESOURCE(Modules);
    Q_INIT_RESOURCE(Tree);
    Q_INIT_RESOURCE(Sequencer);
    Q_INIT_RESOURCE(Common);
    Q_INIT_RESOURCE(Playlist);
    Q_INIT_RESOURCE(Planner);
    Q_INIT_RESOURCE(Boards);
    Q_INIT_RESOURCE(Plugins);
    Q_INIT_RESOURCE(Workspaces);
    Q_INIT_RESOURCE(Settings);
}

void Studio::DestroyResources(void)
{
    Q_CLEANUP_RESOURCE(Resources);
    Q_CLEANUP_RESOURCE(Main);
    Q_CLEANUP_RESOURCE(Default);
    Q_CLEANUP_RESOURCE(Modules);
    Q_CLEANUP_RESOURCE(Tree);
    Q_CLEANUP_RESOURCE(Sequencer);
    Q_CLEANUP_RESOURCE(Common);
    Q_CLEANUP_RESOURCE(Playlist);
    Q_CLEANUP_RESOURCE(Planner);
    Q_CLEANUP_RESOURCE(Boards);
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
    setWindowIcon(QIcon(":/Assets/Logo.png"));
}

Studio::Studio(int argc, char *argv[]) : QGuiApplication(argc, argv)
{
    setOrganizationName("Lexo");
    setOrganizationDomain("lexo-music.com");

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
