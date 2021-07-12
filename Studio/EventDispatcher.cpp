/**
 * @ Author: Cédric Lucchese
 * @ Description: Event Dispatcher cpp
 */

#include "EventDispatcher.hpp"

QStringList EventDispatcher::targetEventList(void) const noexcept
{
    static const QStringList List = {
        "Note 0",
        "Note 1",
        "Note 2",
        "Note 3",
        "Note 4",
        "Note 5",
        "Note 6",
        "Note 7",
        "Note 8",
        "Note 9",
        "Note 10",
        "Note 11",
        "Octave up",
        "Octave down",
        "Play context",
        "Replay context",
        "Stop context",
        "Play playlist",
        "Replay playlist",
        "Stop playlist",
        "Undo",
        "Redo"
        "Copy",
        "Paste",
        "Cut"
    };

    return List;
}

bool EventDispatcher::sendSignals(const AEventListener::EventTarget event, const float value) noexcept
{
    const bool booleanValue = static_cast<bool>(value);

    switch (event) {
    case AEventListener::EventTarget::Action:
        emit action(booleanValue);
        break;
    case AEventListener::EventTarget::Note0:
        emit note0(booleanValue);
        break;
    case AEventListener::EventTarget::Note1:
        emit note1(booleanValue);
        break;
    case AEventListener::EventTarget::Note2:
        emit note2(booleanValue);
        break;
    case AEventListener::EventTarget::Note3:
        emit note3(booleanValue);
        break;
    case AEventListener::EventTarget::Note4:
        emit note4(booleanValue);
        break;
    case AEventListener::EventTarget::Note5:
        emit note5(booleanValue);
        break;
    case AEventListener::EventTarget::Note6:
        emit note6(booleanValue);
        break;
    case AEventListener::EventTarget::Note7:
        emit note7(booleanValue);
        break;
    case AEventListener::EventTarget::Note8:
        emit note8(booleanValue);
        break;
    case AEventListener::EventTarget::Note9:
        emit note9(booleanValue);
        break;
    case AEventListener::EventTarget::Note10:
        emit note10(booleanValue);
        break;
    case AEventListener::EventTarget::Note11:
        emit note11(booleanValue);
        break;
    case AEventListener::EventTarget::OctaveUp:
        emit octaveUp(booleanValue);
        break;
    case AEventListener::EventTarget::OctaveDown:
        emit octaveDown(booleanValue);
        break;
    case AEventListener::EventTarget::PlayContext:
        emit playContext(booleanValue);
        break;
    case AEventListener::EventTarget::ReplayContext:
        emit replayContext(booleanValue);
        break;
    case AEventListener::EventTarget::StopContext:
        emit stopContext(booleanValue);
        break;
    case AEventListener::EventTarget::PlayPlaylist:
        emit playPlaylist(booleanValue);
        break;
    case AEventListener::EventTarget::ReplayPlaylist:
        emit replayPlaylist(booleanValue);
        break;
    case AEventListener::EventTarget::StopPlaylist:
        emit stopPlaylist(booleanValue);
        break;
    default:
        return false;
    }
    return true;
}
