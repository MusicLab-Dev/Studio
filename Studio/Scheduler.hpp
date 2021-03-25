/**
 * @ Author: Cédric Lucchese
 * @ Description: Node Model class
 */

#pragma once

#include <QObject>

#include <Audio/AScheduler.hpp>

#include "Device.hpp"

/**
 * @brief Scheduler class
 */
class Scheduler : public QObject, private Audio::AScheduler
{
    Q_OBJECT

    Q_PROPERTY(Audio::Beat currentBeat READ currentBeat WRITE setCurrentBeat NOTIFY currentBeatChanged)

public:
    static inline const Audio::Device::SDLDescriptor DefaultDeviceDescription {
        /*.name = */ std::string(),
        /*.blockSize = */ 1024u,
        /*.sampleRate = */ 44100,
        /*.isInput = */ false,
        /*.format = */ Audio::Format::Floating32,
        /*.midiChannels = */ 2u,
        /*.channelArrangement = */ Audio::ChannelArrangement::Mono
    };

    using Audio::AScheduler::addEvent;
    using Audio::AScheduler::setProject;

    /** @brief Get the global instance */
    [[nodiscard]] static Scheduler *Get(void) noexcept { return _Instance; }

    /** @brief Default constructor */
    explicit Scheduler(QObject *parent = nullptr);

    /** @brief Destruct the instance */
    ~Scheduler(void) noexcept;


    [[nodiscard]] Audio::Beat currentBeat(void) const noexcept { return Audio::AScheduler::currentBeatRange().from; }

    /** @brief Set the current beat */
    bool setCurrentBeat(const Audio::Beat beat) noexcept;


    /** @brief Audio block generated event */
    void onAudioBlockGenerated(void) override final;

    /** @brief Audio block generated event */
    void onAudioQueueBusy(void) override final;

public slots:
    /** @brief Play the scheduler */
    void play(void);

    /** @brief Pause the scheduler */
    void pause(void);

    /** @brief Stop the scheduler */
    void stop(void);

signals:
    /** @brief Notify that current beat property has changed */
    void currentBeatChanged(void);

    /** @brief Events which Notify to need to apply */
    void needToApplyEvents(void);

    /** @brief Events which Notify to need to notify */
    void needToNotifyEvents(void);

private:
    Device _device;

    static inline Scheduler *_Instance { nullptr };
};
