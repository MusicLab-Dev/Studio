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
    auto type = event->type();
    if (type != QEvent::KeyPress && type != QEvent::KeyRelease)
        return QObject::eventFilter(object, event);
    QKeyEvent *keyEvent = reinterpret_cast<QKeyEvent*>(event);
    if (keyEvent->isAutoRepeat())
        return true;
    auto key = keyEvent->key();
    auto it = _activeKeys.find(key);
    if (event->type() == QEvent::KeyPress && it == _activeKeys.end()) {
        sendSignals(key, true);
        _activeKeys.push(key);
    } else if (event->type() == QEvent::KeyRelease && it != _activeKeys.end()) {
        sendSignals(key, false);
        _activeKeys.erase(it);
    }
    return true;
}

bool KeyboardEventListener::sendSignals(int key, bool value)
{
    for (auto &evt : _events) {
        if (evt.input == key) {
            switch (evt.target) {
            case Event::Target::NOTE_0:
                emit _dispatcher->note0(value);
                break;
            case Event::Target::NOTE_1:
                emit _dispatcher->note1(value);
                break;
            case Event::Target::NOTE_2:
                emit _dispatcher->note2(value);
                break;
            case Event::Target::NOTE_3:
                emit _dispatcher->note3(value);
                break;
            case Event::Target::NOTE_4:
                emit _dispatcher->note4(value);
                break;
            case Event::Target::NOTE_5:
                emit _dispatcher->note5(value);
                break;
            case Event::Target::NOTE_6:
                emit _dispatcher->note6(value);
                break;
            case Event::Target::NOTE_7:
                emit _dispatcher->note7(value);
                break;
            case Event::Target::NOTE_8:
                emit _dispatcher->note8(value);
                break;
            case Event::Target::NOTE_9:
                emit _dispatcher->note9(value);
                break;
            case Event::Target::NOTE_10:
                emit _dispatcher->note10(value);
                break;
            case Event::Target::NOTE_11:
                emit _dispatcher->note11(value);
                break;
            case Event::Target::OCTAVE_UP:
                stopAllPlayingNotes();
                emit _dispatcher->octaveUp(value);
                break;
            case Event::Target::OCTAVE_DOWN:
                stopAllPlayingNotes();
                emit _dispatcher->octaveDown(value);
                break;
            case Event::Target::PLAY_CONTEXT:
                emit _dispatcher->playContext(value);
                break;
            case Event::Target::PAUSE_CONTEXT:
                emit _dispatcher->pauseContext(value);
                break;
            case Event::Target::STOP_CONTEXT:
                emit _dispatcher->stopContext(value);
                break;
            case Event::Target::PLAY_PLAYLIST:
                emit _dispatcher->playPlaylist(value);
                break;
            case Event::Target::PAUSE_PLAYLIST:
                emit _dispatcher->pausePlaylist(value);
                break;
            case Event::Target::STOP_PLAYLIST:
                emit _dispatcher->stopPlaylist(value);
                break;
            default:
                break;
            }
            break;
        }
    }
    return true;
}

void KeyboardEventListener::stopAllPlayingNotes(void)
{
    auto it = std::remove_if(_activeKeys.begin(), _activeKeys.end(), [this](const auto key) {
        for (auto &evt : _events) {
            if (evt.input == key) {
                switch (evt.target) {
                case Event::Target::NOTE_0:
                    emit _dispatcher->note0(false);
                    break;
                case Event::Target::NOTE_1:
                    emit _dispatcher->note1(false);
                    break;
                case Event::Target::NOTE_2:
                    emit _dispatcher->note2(false);
                    break;
                case Event::Target::NOTE_3:
                    emit _dispatcher->note3(false);
                    break;
                case Event::Target::NOTE_4:
                    emit _dispatcher->note4(false);
                    break;
                case Event::Target::NOTE_5:
                    emit _dispatcher->note5(false);
                    break;
                case Event::Target::NOTE_6:
                    emit _dispatcher->note6(false);
                    break;
                case Event::Target::NOTE_7:
                    emit _dispatcher->note7(false);
                    break;
                case Event::Target::NOTE_8:
                    emit _dispatcher->note8(false);
                    break;
                case Event::Target::NOTE_9:
                    emit _dispatcher->note9(false);
                    break;
                case Event::Target::NOTE_10:
                    emit _dispatcher->note10(false);
                    break;
                case Event::Target::NOTE_11:
                    emit _dispatcher->note11(false);
                    break;
                default:
                    return false;
                }
                qDebug() << "Removing key" << key << evt.target;
                return true;
            }
        }
        return false;
    });
    if (it != _activeKeys.end())
        _activeKeys.erase(it, _activeKeys.end());
}
