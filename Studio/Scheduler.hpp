/**
 * @ Author: Cédric Lucchese
 * @ Description: Scheduler
 */

#pragma once

#include <QObject>
#include <QTimer>

#include <Audio/AScheduler.hpp>

#include "Device.hpp"
#include "NodeModel.hpp"

/**
 * @brief Scheduler class
 */
class Scheduler : public QObject, private Audio::AScheduler
{
    Q_OBJECT

    Q_PROPERTY(Device* device READ device NOTIFY deviceChanged)
    Q_PROPERTY(PlaybackMode playbackMode READ playbackMode NOTIFY playbackModeChanged)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(quint32 productionCurrentBeat READ productionCurrentBeat WRITE setProductionCurrentBeat NOTIFY productionCurrentBeatChanged)
    Q_PROPERTY(quint32 liveCurrentBeat READ liveCurrentBeat WRITE setLiveCurrentBeat NOTIFY liveCurrentBeatChanged)
    Q_PROPERTY(quint32 partitionCurrentBeat READ partitionCurrentBeat WRITE setPartitionCurrentBeat NOTIFY partitionCurrentBeatChanged)
    Q_PROPERTY(quint32 onTheFlyCurrentBeat READ onTheFlyCurrentBeat WRITE setOnTheFlyCurrentBeat NOTIFY onTheFlyCurrentBeatChanged)

public:
    /** @brief The different types of playback mode */
    enum class PlaybackMode : int {
        Production = static_cast<int>(Audio::PlaybackMode::Production),
        Live = static_cast<int>(Audio::PlaybackMode::Live),
        Partition = static_cast<int>(Audio::PlaybackMode::Partition),
        OnTheFly = static_cast<int>(Audio::PlaybackMode::OnTheFly)
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

    using Audio::AScheduler::addEvent;
    using Audio::AScheduler::project;
    using Audio::AScheduler::setProject;
    using Audio::AScheduler::invalidateCurrentGraph;
    using Audio::AScheduler::getCurrentGraph;
    using Audio::AScheduler::partitionNode;
    using Audio::AScheduler::partitionIndex;
    using Audio::AScheduler::hasExitedGraph;

    /** @brief Number of miss allowed before the graph 'OnTheFly' should stop */
    static constexpr std::uint32_t OnTheFlyMissThreshold = 25;

    /** @brief Get the global instance */
    [[nodiscard]] static Scheduler *Get(void) noexcept { return _Instance; }

    /** @brief Default constructor */
    explicit Scheduler(Audio::ProjectPtr &&project, QObject *parent = nullptr);

    /** @brief Destruct the instance */
    ~Scheduler(void) noexcept;


    /** @brief Get the playback mode */
    [[nodiscard]] PlaybackMode playbackMode(void) const noexcept { return static_cast<PlaybackMode>(Audio::AScheduler::playbackMode()); }

    /** @brief Get running state */
    [[nodiscard]] bool running(void) const noexcept { return AScheduler::state() == AScheduler::State::Play; }


    /** @brief Get the current beat of a given mode */
    [[nodiscard]] Beat currentBeat(void) const noexcept;
    [[nodiscard]] Beat productionCurrentBeat(void) const noexcept { return currentBeatRange<Audio::PlaybackMode::Production>().from; }
    [[nodiscard]] Beat liveCurrentBeat(void) const noexcept { return currentBeatRange<Audio::PlaybackMode::Live>().from; }
    [[nodiscard]] Beat partitionCurrentBeat(void) const noexcept { return currentBeatRange<Audio::PlaybackMode::Partition>().from; }
    [[nodiscard]] Beat onTheFlyCurrentBeat(void) const noexcept { return currentBeatRange<Audio::PlaybackMode::OnTheFly>().from; }

    /** @brief Set the current beat of a given mode */
    void setCurrentBeat(const Beat beat);
    void setProductionCurrentBeat(const Beat beat);
    void setLiveCurrentBeat(const Beat beat);
    void setPartitionCurrentBeat(const Beat beat);
    void setOnTheFlyCurrentBeat(const Beat beat);


    /** @brief Get the current device */
    [[nodiscard]] const Device *device(void) const noexcept { return &_device; }
    [[nodiscard]] Device *device(void) noexcept { return &_device; }

    /** @brief Get device specs */
    [[nodiscard]] const Audio::AudioSpecs &audioSpecs(void) const noexcept { return _audioSpecs; }


public slots:
    /** @brief Play the scheduler */
    void play(const Scheduler::PlaybackMode mode, const Beat startingBeat);

    /** @brief Play the scheduler setting up a partition */
    void playPartition(const Scheduler::PlaybackMode mode, NodeModel *partitionNode, const quint32 partitionIndex, const Beat startingBeat);

    /** @brief Pause the scheduler */
    void pause(const Scheduler::PlaybackMode mode);

    /** @brief Stop the scheduler (pause + reset beat) */
    void stop(const Scheduler::PlaybackMode mode);

    /** @brief Replay the scheduler (stop + play) */
    void replay(const Scheduler::PlaybackMode mode)
        { play(mode, 0u); }

    /** @brief Replay the scheduler setting up a partition (stop + play) */
    void replayPartition(const Scheduler::PlaybackMode mode, NodeModel *partitionNode, const quint32 partitionIndex)
        { playPartition(mode, partitionNode, partitionIndex, 0u); }

    /** @brief Callback that must be called after a node has been deleted */
    void onNodeDeleted(NodeModel *targetNode);

    /** @brief Callback that must be called after a partition has been deleted */
    void onNodePartitionDeleted(NodeModel *targetNode, const quint32 partition);

signals:
    /** @brief Notify when playback mode changed */
    void playbackModeChanged(void);


    /** @brief Notify that production current beat property has changed */
    void productionCurrentBeatChanged(void);

    /** @brief Notify that live current beat property has changed */
    void liveCurrentBeatChanged(void);

    /** @brief Notify that partition current beat property has changed */
    void partitionCurrentBeatChanged(void);

    /** @brief Notify that on the fly current beat property has changed */
    void onTheFlyCurrentBeatChanged(void);


    /** @brief Notify that the running state has changed */
    void runningChanged(void);


    /** @brief Notify that the device has changed */
    void deviceChanged(void);

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
    alignas_cacheline std::atomic<bool> _blockGenerated { false };
    alignas_cacheline std::atomic<std::size_t> _onTheFlyMissCount { false };
    bool _isOnTheFlyMode { false };

    static inline Scheduler *_Instance { nullptr };


    /** @brief Try to intercept the audio thread lock */
    void onCatchingAudioThread(void);


    /** @brief Audio block generated event */
    [[nodiscard]] bool onAudioBlockGenerated(void) override final;

    /** @brief Audio block generated event */
    [[nodiscard]] bool onAudioQueueBusy(void) override final;

    /** @brief Audio callback */
    void consumeAudioData(std::uint8_t *data, const std::size_t size) noexcept;
};
