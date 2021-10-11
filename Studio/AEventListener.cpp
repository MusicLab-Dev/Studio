/**
 * @ Author: Cédric Lucchese
 * @ Description: Abstract event listener cpp
 */

#include "EventDispatcher.hpp"
#include "AEventListener.hpp"

AEventListener::AEventListener(EventDispatcher *dispatcher)
    : QAbstractListModel(dispatcher), _dispatcher(dispatcher)
{
}

QString AEventListener::eventTargetToString(const int eventTarget) const noexcept
{
    switch (static_cast<EventTarget>(eventTarget)) {
    case EventTarget::Action:
        return AEventListener::tr("Action");
    case EventTarget::Note0:
        return AEventListener::tr("Note 0");
    case EventTarget::Note1:
        return AEventListener::tr("Note 1");
    case EventTarget::Note2:
        return AEventListener::tr("Note 2");
    case EventTarget::Note3:
        return AEventListener::tr("Note 3");
    case EventTarget::Note4:
        return AEventListener::tr("Note 4");
    case EventTarget::Note5:
        return AEventListener::tr("Note 5");
    case EventTarget::Note6:
        return AEventListener::tr("Note 6");
    case EventTarget::Note7:
        return AEventListener::tr("Note 7");
    case EventTarget::Note8:
        return AEventListener::tr("Note 8");
    case EventTarget::Note9:
        return AEventListener::tr("Note 9");
    case EventTarget::Note10:
        return AEventListener::tr("Note 10");
    case EventTarget::Note11:
        return AEventListener::tr("Note 11");
    case EventTarget::OctaveUp:
        return AEventListener::tr("Octave Up");
    case EventTarget::OctaveDown:
        return AEventListener::tr("Octave Down");
    case EventTarget::PlayPauseContext:
        return AEventListener::tr("Play / Pause Context");
    case EventTarget::ReplayStopContext:
        return AEventListener::tr("Replay / Stop Context");
    case EventTarget::ReplayContext:
        return AEventListener::tr("Replay Context");
    case EventTarget::StopContext:
        return AEventListener::tr("Stop Context");
    case EventTarget::PlayPauseProject:
        return AEventListener::tr("Play / Pause Project");
    case EventTarget::ReplayProject:
        return AEventListener::tr("Replay Project");
    case EventTarget::StopProject:
        return AEventListener::tr("Stop Project");
    case EventTarget::Copy:
        return AEventListener::tr("Copy");
    case EventTarget::Paste:
        return AEventListener::tr("Paste");
    case EventTarget::Cut:
        return AEventListener::tr("Cut");
    case EventTarget::VolumeContext:
        return AEventListener::tr("Volume Context");
    case EventTarget::VolumeProject:
        return AEventListener::tr("Volume Project");
    case EventTarget::Undo:
        return AEventListener::tr("Undo");
    case EventTarget::Redo:
        return AEventListener::tr("Redo");
    case EventTarget::Erase:
        return AEventListener::tr("Erase");
    case EventTarget::OpenProject:
        return AEventListener::tr("Open Project");
    case EventTarget::ExportProject:
        return AEventListener::tr("Export Project");
    case EventTarget::Save:
        return AEventListener::tr("Save");
    case EventTarget::SaveAs:
        return AEventListener::tr("Save As");
    case EventTarget::Settings:
        return AEventListener::tr("Settings");
    default:
        return AEventListener::tr("Unknown");
    }
}

QString AEventListener::eventTargetToDescription(const int eventTarget) const noexcept
{
    switch (static_cast<EventTarget>(eventTarget)) {
    case EventTarget::Action:
        return AEventListener::tr("Action");
    case EventTarget::Note0:
        return AEventListener::tr("Play note 0 in a sequencer within selected octave");
    case EventTarget::Note1:
        return AEventListener::tr("Play note 1 in a sequencer within selected octave");
    case EventTarget::Note2:
        return AEventListener::tr("Play note 2 in a sequencer within selected octave");
    case EventTarget::Note3:
        return AEventListener::tr("Play note 3 in a sequencer within selected octave");
    case EventTarget::Note4:
        return AEventListener::tr("Play note 4 in a sequencer within selected octave");
    case EventTarget::Note5:
        return AEventListener::tr("Play note 5 in a sequencer within selected octave");
    case EventTarget::Note6:
        return AEventListener::tr("Play note 6 in a sequencer within selected octave");
    case EventTarget::Note7:
        return AEventListener::tr("Play note 7 in a sequencer within selected octave");
    case EventTarget::Note8:
        return AEventListener::tr("Play note 8 in a sequencer within selected octave");
    case EventTarget::Note9:
        return AEventListener::tr("Play note 9 in a sequencer within selected octave");
    case EventTarget::Note10:
        return AEventListener::tr("Play note 10 in a sequencer within selected octave");
    case EventTarget::Note11:
        return AEventListener::tr("Play note 11 in a sequencer within selected octave");
    case EventTarget::OctaveUp:
        return AEventListener::tr("Move selected octave upward");
    case EventTarget::OctaveDown:
        return AEventListener::tr("Move selected octave down");
    case EventTarget::PlayPauseContext:
        return AEventListener::tr("Play / Pause in current tabulation");
    case EventTarget::ReplayStopContext:
        return AEventListener::tr("Replay / Stop in current tabulation");
    case EventTarget::ReplayContext:
        return AEventListener::tr("Replay in current tabulation");
    case EventTarget::StopContext:
        return AEventListener::tr("Stop in current tabulation");
    case EventTarget::PlayPauseProject:
        return AEventListener::tr("Play / Pause global project");
    case EventTarget::ReplayProject:
        return AEventListener::tr("Replay global project");
    case EventTarget::StopProject:
        return AEventListener::tr("Stop global project");
    case EventTarget::Copy:
        return AEventListener::tr("Copy current selection (works over notes and partition instances)");
    case EventTarget::Paste:
        return AEventListener::tr("Paste current selection (works over notes and partition instances)");
    case EventTarget::Cut:
        return AEventListener::tr("Cut current selection (works over notes and partition instances)");
    case EventTarget::VolumeContext:
        return AEventListener::tr("Change the volume in current tabulation");
    case EventTarget::VolumeProject:
        return AEventListener::tr("Change the volume in global project ('Master')");
    case EventTarget::Undo:
        return AEventListener::tr("Undo the last action (works over notes and partition instances)");
    case EventTarget::Redo:
        return AEventListener::tr("Redo the last action (works over notes and partition instances)");
    case EventTarget::Erase:
        return AEventListener::tr("Erase current selection (works over notes and partition instances)");
    case EventTarget::OpenProject:
        return AEventListener::tr("Open an exisiting project file");
    case EventTarget::ExportProject:
        return AEventListener::tr("Export the current project into an audio file");
    case EventTarget::Save:
        return AEventListener::tr("Save the current project");
    case EventTarget::SaveAs:
        return AEventListener::tr("Save the current project into another file");
    case EventTarget::Settings:
        return AEventListener::tr("Open settings menu");
    default:
        return AEventListener::tr("Unknown");
    }
}
