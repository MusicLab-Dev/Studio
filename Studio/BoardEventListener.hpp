/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Event board listener
 */

#pragma once

#include <QObject>
#include <QGuiApplication>

#include <Core/Vector.hpp>

#include <Protocol/Protocol.hpp>

#include "BoardManager.hpp"
#include "AEventListener.hpp"

/** @brief BoardEventListener class */
class BoardEventListener : public AEventListener
{
    Q_OBJECT

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(BoardManager *boardManager READ boardManager WRITE setBoardManager NOTIFY boardManagerChanged)

public:
    enum class Roles {
        Board,
        Input,
        Event
    };

    /** @brief Describes a key */
    struct KeyDescriptor
    {
        int board {};
        int input {};

        [[nodiscard]] bool operator==(const KeyDescriptor &other) const noexcept
            { return board == other.board && input == other.input; }
    };

    /** @brief Describes an assignment */
    struct KeyAssignment
    {
        KeyDescriptor desc {};
        EventTarget event {};

        [[nodiscard]] bool operator==(const KeyAssignment &other) const noexcept
            { return desc == other.desc && event == other.event; }
    };

    /** @brief Default constructor */
    explicit BoardEventListener(EventDispatcher *dispatcher);

    /** @brief Default virtual destructor */
    ~BoardEventListener(void) override = default;

    /** @brief Get the assignment count */
    [[nodiscard]] int count(void) const noexcept { return static_cast<int>(_events.size()); }
    [[nodiscard]] int rowCount(const QModelIndex & = QModelIndex()) const override
        { return count(); }

    /** @brief Query data from model */
    QVariant data(const QModelIndex &index, int role) const override;

    /** @brief Get the roles names */
    QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Get / Set enabled property */
    [[nodiscard]] bool enabled(void) const noexcept { return _enabled; }
    void setEnabled(const bool value) noexcept;

    /** @brief Get / Set enabled property */
    [[nodiscard]] BoardManager *boardManager(void) const noexcept { return _boardManager; }
    void setBoardManager(BoardManager *manager) noexcept;

    /** @brief Event called whenever a board sends a input event */
    bool boardEventFilter(int board, int input, float value);

public slots:
    /** @brief Add new event in the list */
    void add(int board, int input, EventTarget event);

    /** @brief Remove an event in the list */
    void remove(int idx);

signals:
    /** @brief Notify that the enabled property has changed */
    void enabledChanged(void);

    /** @brief Notify that the board manager property has changed */
    void boardManagerChanged(void);

private:
    Core::TinyVector<KeyAssignment> _events;
    Core::TinyVector<KeyDescriptor> _activeKeys {};
    bool _enabled { false };
    BoardManager *_boardManager { nullptr };

    /** @brief Send signals to dispatcher */
    bool sendSignals(const KeyDescriptor &desc, float value);

    /** @brief Find an event in the list */
    [[nodiscard]] int find(const KeyDescriptor &desc);

    /** @brief Stop all notes that are playing */
    void stopAllPlayingNotes(void);
};
