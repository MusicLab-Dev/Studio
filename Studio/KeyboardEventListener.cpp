/**
 * @ Author: Cédric Lucchese
 * @ Description: Keyboard event listener cpp
 */

#include <QDebug>

#include "EventDispatcher.hpp"

void KeyboardEventListener::set(const Event &e)
{
    beginResetModel();

    auto idx = find(e.input);
    if (idx == -1)
        _events.push_back(e);
    else
        _events[idx] = e;
    endResetModel();
}

int KeyboardEventListener::find(int input)
{
    for (int i = 0; i < _events.size(); ++i)
        if (_events[i].input == input)
            return i;
    return -1;
}

bool KeyboardEventListener::eventFilter(QObject *object, QEvent *event)
{
    QKeyEvent *keyEvent = reinterpret_cast<QKeyEvent*>(event);
    QKeyEvent *last = reinterpret_cast<QKeyEvent*>(_last);
    auto key = keyEvent->key();

    if (event->type() == QEvent::KeyPress) {
        if (last->key() == key)
            return false;
        sendSignals(key, true);
    } else if (event->type() == QEvent::KeyRelease && _last->type() != QEvent::KeyRelease)
        sendSignals(key, false);

    _last = event;
    return QObject::eventFilter(object, event);
}

bool KeyboardEventListener::sendSignals(int key, bool value)
{
    for (auto &evt : _events) {
        if (evt.input == key) {
            switch (evt.target) {
            case Event::Target::NOTE_0:
                _dispatcher->note0(value);
                break;
            case Event::Target::NOTE_1:
                _dispatcher->note1(value);
                break;
            case Event::Target::NOTE_2:
                _dispatcher->note2(value);
                break;
            case Event::Target::NOTE_3:
                _dispatcher->note3(value);
                break;
            case Event::Target::NOTE_4:
                _dispatcher->note4(value);
                break;
            case Event::Target::NOTE_5:
                _dispatcher->note5(value);
                break;
            case Event::Target::NOTE_6:
                _dispatcher->note6(value);
                break;
            case Event::Target::NOTE_7:
                _dispatcher->note7(value);
                break;
            case Event::Target::NOTE_8:
                _dispatcher->note8(value);
                break;
            case Event::Target::NOTE_9:
                _dispatcher->note9(value);
                break;
            case Event::Target::NOTE_10:
                _dispatcher->note10(value);
                break;
            case Event::Target::NOTE_11:
                _dispatcher->note11(value);
                break;
            case Event::Target::OCTAVE_UP:
                _dispatcher->octaveUp(value);
                break;
            case Event::Target::OCTAVE_DOWN:
                _dispatcher->octaveDown(value);
                break;
            case Event::Target::PLAY_CONTEXT:
                _dispatcher->playContext(value);
                break;
            case Event::Target::PAUSE_CONTEXT:
                _dispatcher->pauseContext(value);
                break;
            case Event::Target::STOP_CONTEXT:
                _dispatcher->stopContext(value);
                break;
            case Event::Target::PLAY_PLAYLIST:
                _dispatcher->playPlaylist(value);
                break;
            case Event::Target::PAUSE_PLAYLIST:
                _dispatcher->pausePlaylist(value);
                break;
            case Event::Target::STOP_PLAYLIST:
                _dispatcher->stopPlaylist(value);
                break;
            default:
                break;
            }
            break;
        }
    }
    return true;
}
