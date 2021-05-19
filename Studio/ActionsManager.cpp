/**
 * @ Author: Cédric Lucchese
 * @ Description: Actions Manager
 */

#include <QQmlEngine>

#include "ActionsManager.hpp"

ActionsManager::ActionsManager(QObject *parent)
    : QObject(parent)
{
    if (_Instance)
        throw std::runtime_error("ActionsManager::ActionsManager: An instance of the scheduler already exists");
    _Instance = this;
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

ActionsManager::~ActionsManager(void) noexcept
{
    _Instance = nullptr;
}