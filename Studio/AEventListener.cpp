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
        return tr("Action");
    case EventTarget::Note0:
        return tr("Note 0");
    case EventTarget::Note1:
        return tr("Note 1");
    case EventTarget::Note2:
        return tr("Note 2");
    case EventTarget::Note3:
        return tr("Note 3");
    case EventTarget::Note4:
        return tr("Note 4");
    case EventTarget::Note5:
        return tr("Note 5");
    case EventTarget::Note6:
        return tr("Note 6");
    case EventTarget::Note7:
        return tr("Note 7");
    case EventTarget::Note8:
        return tr("Note 8");
    case EventTarget::Note9:
        return tr("Note 9");
    case EventTarget::Note10:
        return tr("Note 10");
    case EventTarget::Note11:
        return tr("Note 11");
    case EventTarget::OctaveUp:
        return tr("Octave Up");
    case EventTarget::OctaveDown:
        return tr("Octave Down");
    case EventTarget::PlayContext:
        return tr("Play Context");
    case EventTarget::ReplayContext:
        return tr("Replay Context");
    case EventTarget::StopContext:
        return tr("Stop Context");
    case EventTarget::PlayProject:
        return tr("Play Project");
    case EventTarget::ReplayProject:
        return tr("Replay Project");
    case EventTarget::StopProject:
        return tr("Stop Project");
    case EventTarget::Copy:
        return tr("Copy");
    case EventTarget::Paste:
        return tr("Paste");
    case EventTarget::Cut:
        return tr("Cut");
    case EventTarget::VolumeContext:
        return tr("Volume Context");
    case EventTarget::VolumeProject:
        return tr("Volume Project");
    case EventTarget::Undo:
        return tr("Undo");
    case EventTarget::Redo:
        return tr("Redo");
    case EventTarget::Erase:
        return tr("Erase");
    case EventTarget::OpenProject:
        return tr("Open Project");
    case EventTarget::ExportProject:
        return tr("Export Project");
    case EventTarget::Save:
        return tr("Save");
    case EventTarget::SaveAs:
        return tr("Save As");
    case EventTarget::Settings:
        return tr("Settings");
    default:
        return tr("Unknown");
    }
}

QString AEventListener::eventTargetToDescription(const int eventTarget) const noexcept
{
    switch (static_cast<EventTarget>(eventTarget)) {
    case EventTarget::Action:
        return tr("Action");
    case EventTarget::Note0:
        return tr("Play note 0 in a sequencer within selected octave");
    case EventTarget::Note1:
        return tr("Play note 1 in a sequencer within selected octave");
    case EventTarget::Note2:
        return tr("Play note 2 in a sequencer within selected octave");
    case EventTarget::Note3:
        return tr("Play note 3 in a sequencer within selected octave");
    case EventTarget::Note4:
        return tr("Play note 4 in a sequencer within selected octave");
    case EventTarget::Note5:
        return tr("Play note 5 in a sequencer within selected octave");
    case EventTarget::Note6:
        return tr("Play note 6 in a sequencer within selected octave");
    case EventTarget::Note7:
        return tr("Play note 7 in a sequencer within selected octave");
    case EventTarget::Note8:
        return tr("Play note 8 in a sequencer within selected octave");
    case EventTarget::Note9:
        return tr("Play note 9 in a sequencer within selected octave");
    case EventTarget::Note10:
        return tr("Play note 10 in a sequencer within selected octave");
    case EventTarget::Note11:
        return tr("Play note 11 in a sequencer within selected octave");
    case EventTarget::OctaveUp:
        return tr("Move selected octave upward");
    case EventTarget::OctaveDown:
        return tr("Move selected octave down");
    case EventTarget::PlayContext:
        return tr("Play / Pause in current tabulation");
    case EventTarget::ReplayContext:
        return tr("Replay in current tabulation");
    case EventTarget::StopContext:
        return tr("Stop in current tabulation");
    case EventTarget::PlayProject:
        return tr("Play global project");
    case EventTarget::ReplayProject:
        return tr("Replay global project");
    case EventTarget::StopProject:
        return tr("Stop global project");
    case EventTarget::Copy:
        return tr("Copy current selection (works over notes and partition instances)");
    case EventTarget::Paste:
        return tr("Paste current selection (works over notes and partition instances)");
    case EventTarget::Cut:
        return tr("Cut current selection (works over notes and partition instances)");
    case EventTarget::VolumeContext:
        return tr("Change the volume in current tabulation");
    case EventTarget::VolumeProject:
        return tr("Change the volume in global project ('Master')");
    case EventTarget::Undo:
        return tr("Undo the last action (works over notes and partition instances)");
    case EventTarget::Redo:
        return tr("Redo the last action (works over notes and partition instances)");
    case EventTarget::Erase:
        return tr("Erase current selection (works over notes and partition instances)");
    case EventTarget::OpenProject:
        return tr("Open an exisiting project file");
    case EventTarget::ExportProject:
        return tr("Export the current project into an audio file");
    case EventTarget::Save:
        return tr("Save the current project");
    case EventTarget::SaveAs:
        return tr("Save the current project into another file");
    case EventTarget::Settings:
        return tr("Open settings menu");
    default:
        return tr("Unknown");
    }
}