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
        PlayProject,
        ReplayProject,
        StopProject,
        Copy,
        Paste,
        Cut,
        VolumeContext,
        VolumeProject,
        Undo,
        Redo,
        Erase,
        OpenProject,
        ExportProject,
        Save,
        SaveAs,
        Settings,
        TotalEventTarget
    };

    Q_ENUM(EventTarget)

    /** @brief Default constructor */
    explicit AEventListener(EventDispatcher *dispatcher);

    /** @brief Virtual destructor */
    ~AEventListener(void) noexcept override = default;

    [[nodiscard]] EventDispatcher *dispatcher(void) { return _dispatcher; }
    [[nodiscard]] const EventDispatcher *dispatcher(void) const { return _dispatcher; }

public slots:
    /** @brief Convert an event target to its name as string */
    QString eventTargetToString(const int eventTarget) const noexcept;

    /** @brief Convert an event target to its description as string */
    QString eventTargetToDescription(const int eventTarget) const noexcept;

protected:
    EventDispatcher *_dispatcher { nullptr };
};
