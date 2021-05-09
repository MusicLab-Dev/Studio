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

    enum Roles {
        Input = 0,
        Target
    };

    struct Event
    {
        enum Target {
            NOTE_0 = 0,
            NOTE_1,
            NOTE_2,
            NOTE_3,
            NOTE_4,
            NOTE_5,
            NOTE_6,
            NOTE_7,
            NOTE_8,
            NOTE_9,
            NOTE_10,
            NOTE_11,
            OCTAVE_UP,
            OCTAVE_DOWN,
            PLAY_CONTEXT,
            REPLAY_CONTEXT,
            STOP_CONTEXT,
            PLAY_PLAYLIST,
            REPLAY_PLAYLIST,
            STOP_PLAYLIST,
            VOLUME_CONTEXT,
            VOLUME_PLAYLIST
        };

        Target target;
        int input;
    };

    /** @brief Default constructor */
    explicit AEventListener(EventDispatcher *dispatcher, QObject *parent = nullptr) : QAbstractListModel(parent), _dispatcher(dispatcher) {}

    /** @brief Virtual destructor */
    ~AEventListener(void) noexcept override = default;

    [[nodiscard]] EventDispatcher *dispatcher(void) { return _dispatcher; }
    [[nodiscard]] const EventDispatcher *dispatcher(void) const { return _dispatcher; }

    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

    [[nodiscard]] int count(void) const noexcept { return static_cast<int>(_events.size()); }


    virtual void set(const Event &event) = 0;

protected:
    QVector<Event> _events {};
    EventDispatcher *_dispatcher { nullptr };

};
