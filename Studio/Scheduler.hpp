/**
 * @ Author: Cédric Lucchese
 * @ Description: Scheduler
 */

#pragma once

#include <QObject>
#include <QTimer>
#include <QElapsedTimer>

#include <Audio/AScheduler.hpp>

#include "Device.hpp"
#include "NodeModel.hpp"

class Application;

/**
 * @brief Scheduler class
 */
class Scheduler : public QObject, private Audio::AScheduler
{
    Q_OBJECT

    Q_PROPERTY(Device* device READ device NOTIFY deviceChanged)
    Q_PROPERTY(PlaybackMode playbackMode READ playbackMode NOTIFY playbackModeChanged)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(Beat currentBeat READ currentBeat WRITE setCurrentBeat NOTIFY currentBeatChanged)
    Q_PROPERTY(BPM bpm READ bpm WRITE setBPM NOTIFY bpmChanged)
    Q_PROPERTY(quint32 analysisTickRate READ analysisTickRate WRITE setAnalysisTickRate NOTIFY analysisTickRateChanged)

public:
    /** @brief The different types of playback mode */
    enum class PlaybackMode : int {
        Production = static_cast<int>(Audio::PlaybackMode::Production),
        Live = static_cast<int>(Audio::PlaybackMode::Live),
        Partition = static_cast<int>(Audio::PlaybackMode::Partition),
        OnTheFly = static_cast<int>(Audio::PlaybackMode::OnTheFly),
        Export = static_cast<int>(Audio::PlaybackMode::Export)
    };
    Q_ENUM(PlaybackMode)

    static inline const Audio::Device::LogicalDescriptor DefaultDeviceDescription {
        /*.name =               */ {},
        /*.blockSize =          */ 1024u,
        /*.sampleRate =         */ 44100,
        /*.isInput =            */ false,
        /*.format =             */ Audio::Format::Floating32,
        /*.midiChannels =       */ 2u,
        /*.channelArrangement = */ Audio::ChannelArrangement::Mono
    };

    static constexpr std::size_t OutOfRangeExportFrameAllocationCount = 15u;

    using Audio::AScheduler::addEvent;
    using Audio::AScheduler::project;
    using Audio::AScheduler::setProject;
    using Audio::AScheduler::invalidateCurrentGraph;
    using Audio::AScheduler::graph;
    using Audio::AScheduler::partitionNode;
    using Audio::AScheduler::partitionIndex;
    using Audio::AScheduler::hasExitedGraph;
    using Audio::AScheduler::bpm;
    using Audio::AScheduler::tempo;

    /** @brief Number of miss allowed before the graph 'OnTheFly' should stop */
    static constexpr std::uint32_t OnTheFlyMissThreshold = 25;

    /** @brief Get the global instance */
    [[nodiscard]] static Scheduler *Get(void) noexcept { return _Instance; }

    /** @brief Default constructor */
    explicit Scheduler(Audio::ProjectPtr &&project, QObject *parent = nullptr);

    /** @brief Destruct the instance */
    ~Scheduler(void) noexcept;

    /** @brief Get the parent application */
    [[nodiscard]] Application *parentApp(void) noexcept
        { return reinterpret_cast<Application *>(parent()); }
    [[nodiscard]] const Application *parentApp(void) const noexcept
        { return reinterpret_cast<const Application *>(parent()); }


    /** @brief Get the playback mode */
    [[nodiscard]] PlaybackMode playbackMode(void) const noexcept { return static_cast<PlaybackMode>(Audio::AScheduler::playbackMode()); }

    /** @brief Get running state */
    [[nodiscard]] bool running(void) const noexcept { return AScheduler::state() == AScheduler::State::Play; }


    /** @brief Get the current beat of a given mode */
    [[nodiscard]] Beat currentBeat(void) const noexcept { return currentBeatRange().from; }

    /** @brief Set the current beat of a given mode */
    void setCurrentBeat(const Beat beat);

    /** @brief Get the current device */
    [[nodiscard]] const Device *device(void) const noexcept { return &_device; }
    [[nodiscard]] Device *device(void) noexcept { return &_device; }

    /** @brief Get device specs */
    [[nodiscard]] const Audio::AudioSpecs &audioSpecs(void) const noexcept { return _audioSpecs; }

    /** @brief Set the BPM */
    void setBPM(const BPM bpm) noexcept;

    /** @brief Get / Set the analysis tick rate */
    [[nodiscard]] quint32 analysisTickRate(void) const noexcept { return _analysisTickRate; }
    void setAnalysisTickRate(const quint32 tickRate) noexcept;


    /** @brief Reset the on the fly miss count */
    void resetOnTheFlyMiss(void) noexcept { _onTheFlyMissCount = 0u; }

public slots:
    /** @brief Play the scheduler */
    void play(const Scheduler::PlaybackMode mode, const Beat startingBeat, const BeatRange &loopRange = BeatRange{});

    /** @brief Play the scheduler setting up a partition */
    void playPartition(const Scheduler::PlaybackMode mode, NodeModel *partitionNode, const quint32 partitionIndex, const Beat startingBeat, const BeatRange &loopRange = BeatRange{});

    /** @brief Pause the scheduler */
    void pause(void);

    /** @brief Stop the scheduler (pause + reset beat) */
    void stop(void);

    /** @brief Callback that must be called after a node has been deleted */
    void onNodeDeleted(NodeModel *targetNode);

    /** @brief Callback that must be called after a partition has been deleted */
    void onNodePartitionDeleted(NodeModel *targetNode, const quint32 partition);

    /** @brief Set the scheduler loop range */
    void setLoopRange(const BeatRange range);

    /** @brief Disable the scheduler loop range */
    void disableLoopRange(void);

    /** @brief Stop the scheduler until its completly off */
    void stopAndWait(void);

    /** @brief Get elapsed time in beat since last play */
    Beat getAudioElapsedBeat(void) const noexcept { return audioElapsedBeat(); }

    /** @brief Reload the device */
    void changeDevice(const QString &name);

    /** @brief Reload the audio specs and the device */
    void reloadAudioSpecs(void);


    /** @brief Export project to given path */
    void exportProject(const QString &path);

signals:
    /** @brief Notify when playback mode changed */
    void playbackModeChanged(void);


    /** @brief Notify that the running state has changed */
    void runningChanged(void);

    /** @brief Notify that the current beat range has changed */
    void currentBeatChanged(void);

    /** @brief Notify that the bpm has changed */
    void bpmChanged(void);

    /** @brief Notify that the device has changed */
    void deviceChanged(void);

    /** @brief Notify that the analysis cache has changed */
    void analysisCacheUpdated(void);

    /** @brief Notify that the analysis tick rate has changed */
    void analysisTickRateChanged(void);

// Harmful functions, do not use
public:
    /** @brief Play the scheduler without checking playback mode */
    bool playImpl(void);

    /** @brief Pause the scheduler without checking playback mode */
    bool pauseImpl(void);

private:
    Device _device;
    QTimer _timer;
    Audio::AudioSpecs _audioSpecs;
    bool _exitGraph { false };
    bool _busy { false };
    bool _isOnTheFlyMode { false };
    quint32 _analysisTickRate { 0 };
    quint32 _currentAnalysisTick { 0 };
    alignas_cacheline std::atomic<bool> _blockGenerated { false };
    alignas_cacheline std::atomic<std::size_t> _onTheFlyMissCount { false };
    Audio::Buffer _exportBuffer {};
    std::size_t _exportIndex { 0u };
    QString _exportPath {};

    static inline Scheduler *_Instance { nullptr };

    /** @brief Get the device description */
    [[nodiscard]] Audio::Device::LogicalDescriptor getDeviceDescriptor(void);


    /** @brief Audio block generated event */
    [[nodiscard]] bool onAudioBlockGenerated(void) final;

    /** @brief Audio queue busy event */
    [[nodiscard]] bool onAudioQueueBusy(void) final;

    /** @brief Export block generated event */
    [[nodiscard]] bool onExportBlockGenerated(void) final;


    /** @brief Try to intercept the audio thread lock */
    void onCatchingAudioThread(void);

    /** @brief Callback called whenever an export frame is ready */
    void onExportFrameReceived(void);


    /** @brief Export completed */
    void onExportCompleted(void);

    /** @brief Export canceled */
    void onExportCanceled(void);


    /** @brief Audio callback */
    void consumeAudioData(std::uint8_t *data, const std::size_t size) noexcept;
};
