/**
 * @ Author: Cédric Lucchese
 * @ Description: Abstract event listener
 */

#pragma once

    #include <QDebug>

#include <QAbstractListModel>
#include <QKeyEvent>
#include <QGuiApplication>

#include "KeyboardEventListener.hpp"

/** @brief AudioAPI class */
class EventDispatcher : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QStringList targetEventList READ targetEventList CONSTANT)
    Q_PROPERTY(KeyboardEventListener* keyboardListener READ keyboardListener NOTIFY keyboardListenerChanged)

public:
    /** @brief Constructor */
    explicit EventDispatcher(QObject *parent = nullptr) : QObject(parent), _keyboardListener(this, parent) {}

    /** @brief Get the target event list */
    [[nodiscard]] QStringList targetEventList(void) const noexcept { return QStringList(); }

    /** @brief Get the keyboard listener */
    [[nodiscard]] KeyboardEventListener *keyboardListener(void) noexcept { return &_keyboardListener; }
    [[nodiscard]] const KeyboardEventListener *keyboardListener(void) const noexcept { return &_keyboardListener; }

signals:
    /** @brief Notify that keyboard listener has changed */
    void keyboardListenerChanged(void);

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
    void pauseContext(bool pressed);
    void stopContext(bool pressed);
    void playPlaylist(bool pressed);
    void pausePlaylist(bool pressed);
    void stopPlaylist(bool pressed);

    // Floating controls
    void volumeContext(float ratio);
    void volumePlaylist(float ratio);

private:
    KeyboardEventListener _keyboardListener;
};
