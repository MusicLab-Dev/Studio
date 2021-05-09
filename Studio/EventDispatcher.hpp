/**
 * @ Author: Cédric Lucchese
 * @ Description: Abstract event listener
 */

#pragma once

#include <QAbstractListModel>
#include <QKeyEvent>
#include <QGuiApplication>

#include "KeyboardEventListener.hpp"
#include "BoardEventListener.hpp"

/** @brief AudioAPI class */
class EventDispatcher : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QStringList targetEventList READ targetEventList CONSTANT)
    Q_PROPERTY(KeyboardEventListener* keyboardListener READ keyboardListener NOTIFY keyboardListenerChanged)
    Q_PROPERTY(BoardEventListener* boardListener READ boardListener NOTIFY boardListenerChanged)

public:
    /** @brief Constructor */
    explicit EventDispatcher(QObject *parent = nullptr) : QObject(parent), _keyboardListener(this), _boardListener(this) {}

    /** @brief Default virtual destructor */
    ~EventDispatcher(void) override = default;

    /** @brief Get the target event list */
    [[nodiscard]] QStringList targetEventList(void) const noexcept;

    /** @brief Get the keyboard listener */
    [[nodiscard]] KeyboardEventListener *keyboardListener(void) noexcept { return &_keyboardListener; }
    [[nodiscard]] const KeyboardEventListener *keyboardListener(void) const noexcept { return &_keyboardListener; }

    /** @brief Get the keyboard listener */
    [[nodiscard]] BoardEventListener *boardListener(void) noexcept { return &_boardListener; }
    [[nodiscard]] const BoardEventListener *boardListener(void) const noexcept { return &_boardListener; }

signals:
    /** @brief Notify that keyboard listener has changed */
    void keyboardListenerChanged(void);

    /** @brief Notify that board listener has changed */
    void boardListenerChanged(void);

    // Boolean controls
    void note0(bool pressed);
    void note1(bool pressed);
    void note2(bool pressed);
    void note3(bool pressed);
    void note4(bool pressed);
    void note5(bool pressed);
    void note6(bool pressed);
    void note7(bool pressed);
    void note8(bool pressed);
    void note9(bool pressed);
    void note10(bool pressed);
    void note11(bool pressed);
    void octaveUp(bool pressed);
    void octaveDown(bool pressed);

    void playContext(bool pressed);
    void replayContext(bool pressed);
    void stopContext(bool pressed);
    void playPlaylist(bool pressed);
    void replayPlaylist(bool pressed);
    void stopPlaylist(bool pressed);

    // Floating controls
    void volumeContext(float ratio);
    void volumePlaylist(float ratio);

private:
    KeyboardEventListener _keyboardListener;
    BoardEventListener _boardListener;
};
