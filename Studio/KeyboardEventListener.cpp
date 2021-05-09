/**
 * @ Author: Cédric Lucchese
 * @ Description: Keyboard event listener cpp
 */

#include <QDebug>

#include "EventDispatcher.hpp"

KeyboardEventListener::KeyboardEventListener(EventDispatcher *dispatcher, QObject *parent)
    : AEventListener(dispatcher, parent)
{
    QGuiApplication::instance()->installEventFilter(this);

    /**  -- DEBUG -- */
    set(AEventListener::Event { AEventListener::Event::NOTE_0,          Qt::Key_Q           });
    set(AEventListener::Event { AEventListener::Event::NOTE_1,          Qt::Key_S           });
    set(AEventListener::Event { AEventListener::Event::NOTE_2,          Qt::Key_D           });
    set(AEventListener::Event { AEventListener::Event::NOTE_3,          Qt::Key_F           });
    set(AEventListener::Event { AEventListener::Event::NOTE_4,          Qt::Key_G           });
    set(AEventListener::Event { AEventListener::Event::NOTE_5,          Qt::Key_H           });
    set(AEventListener::Event { AEventListener::Event::NOTE_6,          Qt::Key_J           });
    set(AEventListener::Event { AEventListener::Event::NOTE_7,          Qt::Key_K           });
    set(AEventListener::Event { AEventListener::Event::NOTE_8,          Qt::Key_L           });
    set(AEventListener::Event { AEventListener::Event::NOTE_9,          Qt::Key_M           });
    set(AEventListener::Event { AEventListener::Event::NOTE_10,         Qt::Key_Ugrave      });
    set(AEventListener::Event { AEventListener::Event::NOTE_11,         Qt::Key_multiply    });
    set(AEventListener::Event { AEventListener::Event::OCTAVE_UP,       Qt::Key_W           });
    set(AEventListener::Event { AEventListener::Event::OCTAVE_DOWN,     Qt::Key_X           });

    set(AEventListener::Event { AEventListener::Event::PLAY_CONTEXT,    Qt::Key_Space       });
    set(AEventListener::Event { AEventListener::Event::REPLAY_CONTEXT,  Qt::Key_A           });
    set(AEventListener::Event { AEventListener::Event::STOP_CONTEXT,    Qt::Key_Z           });

    set(AEventListener::Event{AEventListener::Event::PLAY_PLAYLIST,     Qt::Key_I           });
    set(AEventListener::Event{AEventListener::Event::REPLAY_PLAYLIST,   Qt::Key_O           });
    set(AEventListener::Event{AEventListener::Event::STOP_PLAYLIST,     Qt::Key_P           });
}

void KeyboardEventListener::setEnabled(const bool value) noexcept
{
    if (_enabled == value)
        return;
    _enabled = value;
    if (!_enabled)
        stopAllPlayingNotes();
    emit enabledChanged();
}

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
    if (!_enabled)
        return false;
    auto type = event->type();
    if ((type != QEvent::KeyPress && type != QEvent::KeyRelease))
        return QObject::eventFilter(object, event);
    QKeyEvent *keyEvent = reinterpret_cast<QKeyEvent*>(event);
    if (keyEvent->isAutoRepeat())
        return true;
    auto key = keyEvent->key();
    auto it = _activeKeys.find(key);
    bool catched = false;
    if (event->type() == QEvent::KeyPress && it == _activeKeys.end()) {
        catched = sendSignals(key, true);
        _activeKeys.push(key);
    } else if (event->type() == QEvent::KeyRelease && it != _activeKeys.end()) {
        catched = sendSignals(key, false);
        _activeKeys.erase(it);
    }
    return catched;
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
            case Event::Target::REPLAY_CONTEXT:
                emit _dispatcher->replayContext(value);
                break;
            case Event::Target::STOP_CONTEXT:
                emit _dispatcher->stopContext(value);
                break;
            case Event::Target::PLAY_PLAYLIST:
                emit _dispatcher->playPlaylist(value);
                break;
            case Event::Target::REPLAY_PLAYLIST:
                emit _dispatcher->replayPlaylist(value);
                break;
            case Event::Target::STOP_PLAYLIST:
                emit _dispatcher->stopPlaylist(value);
                break;
            default:
                return false;
            }
            return true;
        }
    }
    return false;
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
                return true;
            }
        }
        return false;
    });
    if (it != _activeKeys.end())
        _activeKeys.erase(it, _activeKeys.end());
}
