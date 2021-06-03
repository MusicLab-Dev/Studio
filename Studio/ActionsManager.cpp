/**
 * @ Author: Cédric Lucchese
 * @ Description: Actions Manager listener
 */

#include <QDebug>

#include "ActionsManager.hpp"

void ActionsManager::undo(void) noexcept
{
    if (_index > 0) {
        _index--;
        emit undoProcess(_actions[_index]);

        qDebug() << "undo";
    }
}

void ActionsManager::redo(void) noexcept
{
    if (_index < _actions.size() - 1) {
        _index++;
        emit redoProcess(_actions[_index]);

        qDebug() << "redo";
    }
}

QVariantList ActionsManager::lastAction(void) noexcept
{
    if (_index - 1 > 0)
        return _actions[_index - 1];
    return QVariantList();
}

void ActionsManager::push(const QVariantList &var) noexcept
{
    _actions.remove(_index, _actions.size() - _index);
    _actions.push_back(var);
    _index++;

    qDebug() << "push" << var;
}