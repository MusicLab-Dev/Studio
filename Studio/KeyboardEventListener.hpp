/**
 * @ Author: Cédric Lucchese
 * @ Description: Abstract event Keyboard Event Listener
 */

#pragma once

#include <QObject>
#include <QGuiApplication>

#include "AEventListener.hpp"

/** @brief KeyboardEventListener class */
class KeyboardEventListener : public AEventListener
{
public:
    /** @brief Default constructor */
    explicit KeyboardEventListener(EventDispatcher *dispatcher, QObject *parent = nullptr) : AEventListener(dispatcher, parent)
    {
        QGuiApplication::instance()->installEventFilter(this);

        /**  -- DEBUG -- */
        set(AEventListener::Event{AEventListener::Event::NOTE_0, 81});
        set(AEventListener::Event{AEventListener::Event::NOTE_1, 83});
        set(AEventListener::Event{AEventListener::Event::NOTE_2, 68});
        set(AEventListener::Event{AEventListener::Event::NOTE_3, 70});
        set(AEventListener::Event{AEventListener::Event::NOTE_4, 71});
        set(AEventListener::Event{AEventListener::Event::NOTE_5, 72});
        set(AEventListener::Event{AEventListener::Event::NOTE_6, 74});
        set(AEventListener::Event{AEventListener::Event::NOTE_7, 75});
        set(AEventListener::Event{AEventListener::Event::NOTE_8, 76});
        set(AEventListener::Event{AEventListener::Event::NOTE_9, 77});
        set(AEventListener::Event{AEventListener::Event::NOTE_10, 66});
        set(AEventListener::Event{AEventListener::Event::NOTE_11, 78});
        set(AEventListener::Event{AEventListener::Event::OCTAVE_UP, 87});
        set(AEventListener::Event{AEventListener::Event::OCTAVE_DOWN, 88});
    };

    /** @brief add new event in the list */
    void set(const AEventListener::Event &event) override;

    /** @brief get users inputs */
    bool eventFilter(QObject *object, QEvent *Event) override;

private:
    QEvent *_last {nullptr};

    /** @brief send signals */
    bool sendSignals(int key, bool value);

    int find(int key);

};