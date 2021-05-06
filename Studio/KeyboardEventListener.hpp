/**
 * @ Author: Cédric Lucchese
 * @ Description: Abstract event Keyboard Event Listener
 */

#pragma once

#include <QObject>
#include <QGuiApplication>

#include <Core/Vector.hpp>

#include "AEventListener.hpp"

/** @brief KeyboardEventListener class */
class KeyboardEventListener : public AEventListener
{
    Q_OBJECT

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

public:
    /** @brief Default constructor */
    explicit KeyboardEventListener(EventDispatcher *dispatcher, QObject *parent = nullptr);

    /** @brief Add new event in the list */
    void set(const AEventListener::Event &event) override;

    /** @brief Get users inputs */
    bool eventFilter(QObject *object, QEvent *Event) override;

    /** @brief Get / Set enabled property */
    [[nodiscard]] bool enabled(void) const noexcept { return _enabled; }
    void setEnabled(const bool value) noexcept;

signals:
    void enabledChanged(void);

private:
    Core::TinyVector<int> _activeKeys {};
    bool _enabled { false };

    /** @brief send signals */
    bool sendSignals(int key, bool value);

    int find(int key);

    /** @brief Stop all notes that are playing */
    void stopAllPlayingNotes(void);

};
