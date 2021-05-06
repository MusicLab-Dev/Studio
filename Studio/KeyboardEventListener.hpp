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
public:
    /** @brief Default constructor */
    explicit KeyboardEventListener(EventDispatcher *dispatcher, QObject *parent = nullptr);

    /** @brief add new event in the list */
    void set(const AEventListener::Event &event) override;

    /** @brief get users inputs */
    bool eventFilter(QObject *object, QEvent *Event) override;

private:
    Core::TinyVector<int> _activeKeys {};

    /** @brief send signals */
    bool sendSignals(int key, bool value);

    int find(int key);

    /** @brief Stop all notes that are playing */
    void stopAllPlayingNotes(void);

};
