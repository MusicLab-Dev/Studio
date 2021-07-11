/**
 * @ Author: Cédric Lucchese
 * @ Description: Abstract event listener
 */

#pragma once

#include <QAbstractListModel>
#include <QKeyEvent>

class EventDispatcher;

/** @brief AudioAPI class */
class AEventListener : public QAbstractListModel
{
    Q_OBJECT

public:
    enum class EventTarget {
        Action = 0,
        Note0,
        Note1,
        Note2,
        Note3,
        Note4,
        Note5,
        Note6,
        Note7,
        Note8,
        Note9,
        Note10,
        Note11,
        OctaveUp,
        OctaveDown,
        PlayContext,
        ReplayContext,
        StopContext,
        PlayPlaylist,
        ReplayPlaylist,
        StopPlaylist,
        VolumeContext,
        VolumePlaylist
    };

    Q_ENUM(EventTarget)

    /** @brief Default constructor */
    explicit AEventListener(EventDispatcher *dispatcher);

    /** @brief Virtual destructor */
    ~AEventListener(void) noexcept override = default;

    [[nodiscard]] EventDispatcher *dispatcher(void) { return _dispatcher; }
    [[nodiscard]] const EventDispatcher *dispatcher(void) const { return _dispatcher; }

protected:
    EventDispatcher *_dispatcher { nullptr };
};
