/**
 * @ Author: Cédric Lucchese
 * @ Description: Node Model class
 */

#pragma once

#include <QObject>

#include <MLAudio/Scheduler.hpp>

/**
 * @brief Scheduler class
 */
class Scheduler : public QObject, Audio::AScheduler
{
    Q_OBJECT

    Q_PROPERTY(Audio::Beat currentBeat READ currentBeat WRITE setCurrentBeat NOTIFY currentBeatChanged)

public:
    /** @brief Default constructor */
    explicit Scheduler(QObject *parent = nullptr) noexcept;

    /** @brief Destruct the instance */
    ~Scheduler(void) noexcept = default;


    /** @brief Get the current beat */
    Audio::Beat currentBeat(void) const noexcept { return _data->currentBeat(); }

    /** @brief Set the current beat */
    bool setCurrentBeat(const Audio::Beat &beat) noexcept;

    /** @brief Audio block generated event */
    void onAudioBlockGenerated(void) override final;

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
    Audio::Scheduler *_data { nullptr };
}
