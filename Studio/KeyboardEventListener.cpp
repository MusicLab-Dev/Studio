/**
 * @ Author: Cédric Lucchese
 * @ Description: Keyboard event listener
 */

#include "EventDispatcher.hpp"

KeyboardEventListener::KeyboardEventListener(EventDispatcher *dispatcher)
    : AEventListener(dispatcher)
{
    QGuiApplication::instance()->installEventFilter(this);

    /**  -- DEBUG -- */
    add(Qt::Key_Q,          0, EventTarget::Note0           );
    add(Qt::Key_S,          0, EventTarget::Note1           );
    add(Qt::Key_D,          0, EventTarget::Note2           );
    add(Qt::Key_F,          0, EventTarget::Note3           );
    add(Qt::Key_G,          0, EventTarget::Note4           );
    add(Qt::Key_H,          0, EventTarget::Note5           );
    add(Qt::Key_J,          0, EventTarget::Note6           );
    add(Qt::Key_K,          0, EventTarget::Note7           );
    add(Qt::Key_L,          0, EventTarget::Note8           );
    add(Qt::Key_M,          0, EventTarget::Note9           );
    add(Qt::Key_Ugrave,     0, EventTarget::Note10          );
    add(Qt::Key_Asterisk,   0, EventTarget::Note11          );
    add(Qt::Key_W,          0, EventTarget::OctaveDown      );
    add(Qt::Key_X,          0, EventTarget::OctaveUp        );
    add(Qt::Key_Colon,      0, EventTarget::OctaveDown      );
    add(Qt::Key_Exclam,     0, EventTarget::OctaveUp        );

    add(Qt::Key_Space,      0, EventTarget::PlayContext     );
    add(Qt::Key_A,          0, EventTarget::ReplayContext   );
    add(Qt::Key_Z,          0, EventTarget::StopContext     );

    add(Qt::Key_I,          0, EventTarget::PlayPlaylist    );
    add(Qt::Key_O,          0, EventTarget::ReplayPlaylist  );
    add(Qt::Key_P,          0, EventTarget::StopPlaylist    );
   
    add(Qt::Key_C,          Qt::CTRL, EventTarget::Copy     );
    add(Qt::Key_V,          Qt::CTRL, EventTarget::Paste    );
}


QHash<int, QByteArray> KeyboardEventListener::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::Key), "eventKey" },
        { static_cast<int>(Roles::Modifiers), "eventModifiers" },
        { static_cast<int>(Roles::Event), "eventType" }
    };
}

QVariant KeyboardEventListener::data(const QModelIndex &index, int role) const
{
    auto &event = _events[static_cast<std::uint32_t>(index.row())];

    switch (static_cast<Roles>(role)) {
        case Roles::Key:
            return event.desc.key;
        case Roles::Modifiers:
            return event.desc.modifiers;
        case Roles::Event:
            return event.event;
        default:
            return QVariant();
    }
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

void KeyboardEventListener::add(int key, int modifiers, EventTarget event)
{
    const KeyDescriptor desc { key, modifiers };
    auto idx = find(desc);

    if (idx == -1) {
        beginInsertRows(QModelIndex(), count(), count());
        _events.push(KeyAssignment {
            desc,
            event
        });
        endInsertRows();
    } else {
        _events[static_cast<std::uint32_t>(idx)].event = event;
        emit dataChanged(index(idx), index(idx), {});
    }
}

void KeyboardEventListener::remove(const int idx)
{
    if (idx < 0 || idx >= count())
        return;
    stopAllPlayingNotes();
    beginRemoveRows(QModelIndex(), idx, idx);
    auto it = _activeKeys.find(_events[static_cast<std::uint32_t>(idx)].desc);
    if (it != _activeKeys.end())
        _activeKeys.erase(it);
    _events.erase(_events.begin() + idx);
    endRemoveRows();
}

int KeyboardEventListener::find(const KeyDescriptor &desc)
{
    for (auto i = 0u; i < _events.size(); ++i) {
        auto &evt = _events[i];
        if (evt.desc == desc)
            return static_cast<int>(i);
    }
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
    const KeyDescriptor desc { keyEvent->key(), static_cast<int>(keyEvent->modifiers()) };
    auto it = _activeKeys.find(desc);
    bool catched = false;
    if (event->type() == QEvent::KeyPress && it == _activeKeys.end()) {
        catched = sendSignals(desc, true);
        _activeKeys.push(desc);
    } else if (event->type() == QEvent::KeyRelease && it != _activeKeys.end()) {
        catched = sendSignals(desc, false);
        _activeKeys.erase(it);
    }
    return catched;
}

bool KeyboardEventListener::sendSignals(const KeyDescriptor &desc, bool value)
{
    auto idx = find(desc);
    if (idx == -1)
        return false;
    const auto &event = _events[static_cast<std::uint32_t>(idx)];
    switch (event.event) {
    case EventTarget::Note0:
        emit _dispatcher->note0(value);
        break;
    case EventTarget::Note1:
        emit _dispatcher->note1(value);
        break;
    case EventTarget::Note2:
        emit _dispatcher->note2(value);
        break;
    case EventTarget::Note3:
        emit _dispatcher->note3(value);
        break;
    case EventTarget::Note4:
        emit _dispatcher->note4(value);
        break;
    case EventTarget::Note5:
        emit _dispatcher->note5(value);
        break;
    case EventTarget::Note6:
        emit _dispatcher->note6(value);
        break;
    case EventTarget::Note7:
        emit _dispatcher->note7(value);
        break;
    case EventTarget::Note8:
        emit _dispatcher->note8(value);
        break;
    case EventTarget::Note9:
        emit _dispatcher->note9(value);
        break;
    case EventTarget::Note10:
        emit _dispatcher->note10(value);
        break;
    case EventTarget::Note11:
        emit _dispatcher->note11(value);
        break;
    case EventTarget::OctaveUp:
        stopAllPlayingNotes();
        emit _dispatcher->octaveUp(value);
        break;
    case EventTarget::OctaveDown:
        stopAllPlayingNotes();
        emit _dispatcher->octaveDown(value);
        break;
    case EventTarget::PlayContext:
        emit _dispatcher->playContext(value);
        break;
    case EventTarget::ReplayContext:
        emit _dispatcher->replayContext(value);
        break;
    case EventTarget::StopContext:
        emit _dispatcher->stopContext(value);
        break;
    case EventTarget::PlayPlaylist:
        emit _dispatcher->playPlaylist(value);
        break;
    case EventTarget::ReplayPlaylist:
        emit _dispatcher->replayPlaylist(value);
        break;
    case EventTarget::StopPlaylist:
        emit _dispatcher->stopPlaylist(value);
        break;
    case EventTarget::Copy:
        emit _dispatcher->copy(value);
        break;
    case EventTarget::Paste:
        emit _dispatcher->paste(value);
        break;
    default:
        return false;
    }
    return true;
}

void KeyboardEventListener::stopAllPlayingNotes(void)
{
    auto it = std::remove_if(_activeKeys.begin(), _activeKeys.end(), [this](const auto &desc) {
        for (auto &evt : _events) {
            if (evt.desc == desc) {
                switch (evt.event) {
                case EventTarget::Note0:
                    emit _dispatcher->note0(false);
                    break;
                case EventTarget::Note1:
                    emit _dispatcher->note1(false);
                    break;
                case EventTarget::Note2:
                    emit _dispatcher->note2(false);
                    break;
                case EventTarget::Note3:
                    emit _dispatcher->note3(false);
                    break;
                case EventTarget::Note4:
                    emit _dispatcher->note4(false);
                    break;
                case EventTarget::Note5:
                    emit _dispatcher->note5(false);
                    break;
                case EventTarget::Note6:
                    emit _dispatcher->note6(false);
                    break;
                case EventTarget::Note7:
                    emit _dispatcher->note7(false);
                    break;
                case EventTarget::Note8:
                    emit _dispatcher->note8(false);
                    break;
                case EventTarget::Note9:
                    emit _dispatcher->note9(false);
                    break;
                case EventTarget::Note10:
                    emit _dispatcher->note10(false);
                    break;
                case EventTarget::Note11:
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
