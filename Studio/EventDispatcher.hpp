/**
 * @ Author: Cédric Lucchese
 * @ Description: Abstract event listener
 */

#pragma once

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
    explicit EventDispatcher(QObject *parent = nullptr) : QObject(parent), _keyboardListener(this) {}

    /** @brief Default virtual destructor */
    ~EventDispatcher(void) override = default;

    /** @brief Get the target event list */
    [[nodiscard]] QStringList targetEventList(void) const noexcept;

    /** @brief Get the keyboard listener */
    [[nodiscard]] KeyboardEventListener *keyboardListener(void) noexcept { return &_keyboardListener; }
    [[nodiscard]] const KeyboardEventListener *keyboardListener(void) const noexcept { return &_keyboardListener; }

    /** @brief Send boolean signals */
    bool sendSignals(const AEventListener::EventTarget event, const bool value) noexcept
        { return sendSignals(event, static_cast<float>(value)); }

    /** @brief Send floating signals */
    bool sendSignals(const AEventListener::EventTarget event, const float value) noexcept;

signals:
    /** @brief Notify that keyboard listener has changed */
    void keyboardListenerChanged(void);

    // Events
    void action(bool pressed);

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

    void playPauseContext(bool pressed);
    void replayStopContext(bool pressed);
    void replayContext(bool pressed);
    void stopContext(bool pressed);
    void playPauseProject(bool pressed);
    void replayProject(bool pressed);
    void stopProject(bool pressed);

    void copy(bool pressed);
    void paste(bool pressed);
    void cut(bool pressed);
    void erase(bool pressed);

    // Floating controls
    void volumeContext(float ratio);
    void volumeProject(float ratio);

    // Undo / Redo
    void undo(bool pressed);
    void redo(bool pressed);

    // Project
    void openProject(bool pressed);
    void exportProject(bool pressed);
    void save(bool pressed);
    void saveAs(bool pressed);

    // Settings
    void settings(bool pressed);

private:
    KeyboardEventListener _keyboardListener;
};
