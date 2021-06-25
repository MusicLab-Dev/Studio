/**
 * @ Author: Cédric Lucchese
 * @ Description: Actions Manager
 */

#include <QQmlEngine>

#include "Base.hpp"

#include "ActionsManager.hpp"
#include "PartitionModel.hpp"

ActionsManager::ActionsManager(QObject *parent)
    : QObject(parent)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

bool ActionsManager::push(const Action &action, const QVariantList &args) noexcept
{ 
    if (_events.size() > _index + 1)
        _events.remove(_index, _events.size() - _index);
    
    qDebug() << action << args;
    _events.push_back({action, args});
    _index++;
    return true;
}

bool ActionsManager::undo(void)
{
    if (_index <= 0)
        return false;

    qDebug() << _index;

    auto &event = current();
    _index--;

    switch (event.action)
    {
        case Action::ADD_NOTE:
            return actionAddNote(Type::UNDO, event.args);
        case Action::REMOVE_NOTE:
            return actionRemoveNote(Type::UNDO, event.args);
        case Action::MOVE_NOTE:
            return actionMoveNote(Type::UNDO, event.args);
        default:
            return false;
    }

}

bool ActionsManager::redo(void)
{
    return false;
}

bool ActionsManager::actionAddNote(const Type &type, const QVariantList &args)
{
    PartitionModel *partition = qvariant_cast<PartitionModel *>(args[0]);
    if (!partition)
        return false;

    auto from = args[1].toInt();
    auto to = args[2].toInt();
    auto key = args[3].toInt();
    auto velocity = args[4].toInt();
    auto tuning = args[5].toInt();

    if (type == Type::UNDO) {
        int idx = partition->find(key, from);
        if (idx == -1) {
            qDebug() << "UNDO: actionAddNote error (idx == -1)";
            return false;
        }

        try {
            if (_index > 1) {
                auto &last = current();
                if (last.action == Action::MOVE_NOTE) {
                    partition->set(idx, {
                                       {Audio::Beat(last.args[1].toInt()), Audio::Beat(last.args[2].toInt())},
                                        Audio::Key(last.args[3].toInt()),
                                        Audio::Velocity(last.args[4].toInt()),
                                        Audio::Tuning(last.args[5].toInt())});
                    _index--;
                    qDebug() << "UNDO: actionMoveNote Success";
                    return true;
                }
            }
        } catch (const std::range_error &e) {
            return true;
        }

        partition->remove(idx);
        qDebug() << "UNDO: actionAddNote success";
        return true;
    }

    if (type == Type::REDO) {
        partition->add({{Audio::Beat(from), Audio::Beat(to)},
                        Audio::Key(key),
                        Audio::Velocity(velocity),
                        Audio::Tuning(tuning)});
        qDebug() << "REDO: actionAddNote success";
        return true;
    }

    return false;
}

bool ActionsManager::actionRemoveNote(const Type &type, const QVariantList &args)
{
    PartitionModel *partition = qvariant_cast<PartitionModel *>(args[0]);
    if (!partition)
        return false;

    auto from = args[1].toInt();
    auto to = args[2].toInt();
    auto key = args[3].toInt();
    auto velocity = args[4].toInt();
    auto tuning = args[5].toInt();

    if (type == Type::UNDO) {
        partition->add({{Audio::Beat(from), Audio::Beat(to)},
                        Audio::Key(key),
                        Audio::Velocity(velocity),
                        Audio::Tuning(tuning)});
        qDebug() << "UNDO: actionRemoveNote success";
        return true;
    }

    if (type == Type::REDO) {
        int idx = partition->find(key, from);
        if (idx == -1) {
            qDebug() << "REDO: actionRemoveNote error (idx == -1)";
            return false;
        }
        partition->remove(idx);
        qDebug() << "REDO: actionRemoveNote success";
        return true;
    }

}

bool ActionsManager::actionMoveNote(const Type &type, const QVariantList &args)
{
    PartitionModel *partition = qvariant_cast<PartitionModel *>(args[0]);
    if (!partition)
        return false;

    auto from = args[1].toInt();
    auto to = args[2].toInt();
    auto key = args[3].toInt();
    auto velocity = args[4].toInt();
    auto tuning = args[5].toInt();

    if (type == Type::UNDO) {
        partition->add({{Audio::Beat(from), Audio::Beat(to)},
                        Audio::Key(key),
                        Audio::Velocity(velocity),
                        Audio::Tuning(tuning)});
        qDebug() << "UNDO: actionMoveNote success";
    }
}
