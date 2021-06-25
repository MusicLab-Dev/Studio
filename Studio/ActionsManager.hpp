/**
 * @ Author: Cédric Lucchese
 * @ Description: Actions Manager
 */

#pragma once

/** @brief Actions Manager class */
class ActionsManager : public QObject
{
    Q_OBJECT
    
public:
    enum class Action {
        NOTHING,

        ADD_NOTE,
        ADD_PARTITION,
        ADD_NODE,

        REMOVE_NOTE,
        REMOVE_PARTITION,
        REMOVE_NODE,
        
        MOVE_NOTE,
        MOVE_PARTITION,
        MOVE_NODE,
    };
    Q_ENUM(Action);

    enum class Type {
        UNDO,
        REDO
    };

    struct Event {
        Action action {Action::NOTHING};
        QVariantList args {};
    };

    /** @brief Default constructor */
    explicit ActionsManager(QObject *parent = nullptr);

    /** @brief get current event */
    [[nodiscard]] const Event &current(void) const noexcept { return _events[_index - 1]; }
    [[nodiscard]] Event &current(void) noexcept { return _events[_index - 1]; }

    /** @brief get after event */
    [[nodiscard]] const Event &after(void) const { if (_index + 1 > _events.size()) throw std::range_error("ActionsManager::after idx out"); return _events[_index]; }
    [[nodiscard]] Event &after(void) { if (_index + 1 > _events.size()) throw std::range_error("ActionsManager::after idx out"); return _events[_index]; }

public slots:
    /** @brief Push a new event in the stack */
    bool push(const Action &action, const QVariantList &args) noexcept;
    
    /** @brief Process the undo */
    bool undo(void);

    /** @brief Process the redo */
    bool redo(void);

private:
    QVector<Event> _events {};
    int _index = 0;

    bool actionAddNote(const Type &type, const QVariantList &args);
    bool actionRemoveNote(const Type &type, const QVariantList &args);
    bool actionMoveNote(const Type &type, const QVariantList &args);
};
