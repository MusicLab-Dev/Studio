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
    };

    return List;
}
