/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Board event listener
 */

#include "EventDispatcher.hpp"

BoardEventListener::BoardEventListener(EventDispatcher *dispatcher)
    : AEventListener(dispatcher)
{
}

QHash<int, QByteArray> BoardEventListener::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::Board), "eventBoard" },
        { static_cast<int>(Roles::Input), "eventInput" },
        { static_cast<int>(Roles::Event), "eventType" }
    };
}

QVariant BoardEventListener::data(const QModelIndex &index, int role) const
{
    auto &event = _events[static_cast<std::uint32_t>(index.row())];

    switch (static_cast<Roles>(role)) {
        case Roles::Board:
            return event.desc.board;
        case Roles::Input:
            return event.desc.input;
        case Roles::Event:
            return event.event;
        default:
            return QVariant();
    }
}

void BoardEventListener::setEnabled(const bool value) noexcept
{
    if (_enabled == value)
        return;
    _enabled = value;
    if (!_enabled)
        stopAllPlayingNotes();
    emit enabledChanged();
}

void BoardEventListener::setBoardManager(BoardManager *manager) noexcept
{
    if (_boardManager)
        disconnect(_boardManager, &BoardManager::boardEvent, this, &BoardEventListener::boardEventFilter);
    if (_boardManager == manager)
        return;
    _boardManager = manager;
    if (_boardManager)
        connect(_boardManager, &BoardManager::boardEvent, this, &BoardEventListener::boardEventFilter);
    emit boardManagerChanged();
}

void BoardEventListener::add(const int key, const int modifiers, EventTarget event)
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

void BoardEventListener::remove(const int idx)
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

int BoardEventListener::find(const KeyDescriptor &desc)
{
    for (auto i = 0u; i < _events.size(); ++i) {
        auto &evt = _events[i];
        if (evt.desc == desc)
            return static_cast<int>(i);
    }
    return -1;
}

bool BoardEventListener::boardEventFilter(int board, int input, float value)
{
    if (!_enabled)
        return false;
    const KeyDescriptor desc { board, input };
    auto it = _activeKeys.find(desc);
    bool catched = false;
    if (value == 1.0f && it == _activeKeys.end()) {
        _activeKeys.push(desc);
        catched = sendSignals(desc, value);
    } else if (it != _activeKeys.end()) {
        catched = sendSignals(desc, value);
        _activeKeys.erase(it);
    }
    return catched;
}

bool BoardEventListener::sendSignals(const KeyDescriptor &desc, float value)
{
    const bool boolValue = static_cast<bool>(value);
    auto idx = find(desc);
    if (idx == -1)
        return false;
    const auto &event = _events[static_cast<std::uint32_t>(idx)];
    switch (event.event) {
    case EventTarget::Note0:
        emit _dispatcher->note0(boolValue);
        break;
    case EventTarget::Note1:
        emit _dispatcher->note1(boolValue);
        break;
    case EventTarget::Note2:
        emit _dispatcher->note2(boolValue);
        break;
    case EventTarget::Note3:
        emit _dispatcher->note3(boolValue);
        break;
    case EventTarget::Note4:
        emit _dispatcher->note4(boolValue);
        break;
    case EventTarget::Note5:
        emit _dispatcher->note5(boolValue);
        break;
    case EventTarget::Note6:
        emit _dispatcher->note6(boolValue);
        break;
    case EventTarget::Note7:
        emit _dispatcher->note7(boolValue);
        break;
    case EventTarget::Note8:
        emit _dispatcher->note8(boolValue);
        break;
    case EventTarget::Note9:
        emit _dispatcher->note9(boolValue);
        break;
    case EventTarget::Note10:
        emit _dispatcher->note10(boolValue);
        break;
    case EventTarget::Note11:
        emit _dispatcher->note11(boolValue);
        break;
    case EventTarget::OctaveUp:
        stopAllPlayingNotes();
        emit _dispatcher->octaveUp(boolValue);
        break;
    case EventTarget::OctaveDown:
        stopAllPlayingNotes();
        emit _dispatcher->octaveDown(boolValue);
        break;
    case EventTarget::PlayContext:
        emit _dispatcher->playContext(boolValue);
        break;
    case EventTarget::ReplayContext:
        emit _dispatcher->replayContext(boolValue);
        break;
    case EventTarget::StopContext:
        emit _dispatcher->stopContext(boolValue);
        break;
    case EventTarget::PlayPlaylist:
        emit _dispatcher->playPlaylist(boolValue);
        break;
    case EventTarget::ReplayPlaylist:
        emit _dispatcher->replayPlaylist(boolValue);
        break;
    case EventTarget::StopPlaylist:
        emit _dispatcher->stopPlaylist(boolValue);
        break;
    default:
        return false;
    }
    return true;
}

void BoardEventListener::stopAllPlayingNotes(void)
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
