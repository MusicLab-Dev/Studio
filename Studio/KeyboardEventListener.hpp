/**
 * @ Author: Cédric Lucchese
 * @ Description: Keyboard event listener
 */

#pragma once

#include <QObject>
#include <QGuiApplication>

#include <Core/Vector.hpp>

#include "AEventListener.hpp"

/** @brief KeyboardEventListener class */
class KeyboardEventListener : public AEventListener
{
    Q_OBJECT

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

public:
    enum class Roles {
        Key,
        Modifiers,
        Event
    };

    /** @brief Describes a key */
    struct KeyDescriptor
    {
        int key {};
        int modifiers {};

        [[nodiscard]] bool operator==(const KeyDescriptor &other) const noexcept
            { return key == other.key && modifiers == other.modifiers; }
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
    explicit KeyboardEventListener(EventDispatcher *dispatcher);

    /** @brief Default virtual destructor */
    ~KeyboardEventListener(void) override = default;

    /** @brief Get the assignment count */
    [[nodiscard]] int count(void) const noexcept { return static_cast<int>(_events.size()); }
    [[nodiscard]] int rowCount(const QModelIndex & = QModelIndex()) const override
        { return count(); }

    /** @brief Query data from model */
    QVariant data(const QModelIndex &index, int role) const override;

    /** @brief Get the roles names */
    QHash<int, QByteArray> roleNames(void) const noexcept override;


    /** @brief Get users inputs */
    bool eventFilter(QObject *object, QEvent *Event) override;

    /** @brief Get / Set enabled property */
    [[nodiscard]] bool enabled(void) const noexcept { return _enabled; }
    void setEnabled(const bool value) noexcept;

public slots:
    /** @brief Add new event in the list */
    void add(int key, int modifiers, EventTarget event);

    /** @brief Remove an event in the list */
    void remove(int idx);

signals:
    /** @brief Notify that the enabled property has changed */
    void enabledChanged(void);

private:
    Core::TinyVector<KeyAssignment> _events;
    Core::TinyVector<KeyDescriptor> _activeKeys {};
    bool _enabled { false };

    /** @brief Send signals to dispatcher */
    bool sendSignals(const KeyDescriptor &desc, bool value);

    /** @brief Find an event in the list */
    [[nodiscard]] int find(const KeyDescriptor &desc);

    /** @brief Stop all notes that are playing */
    void stopAllPlayingNotes(void);
};
