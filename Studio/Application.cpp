/**
 * @ Author: Cédric Lucchese
 * @ Description: Main Application implementation
 */

#include <QQmlEngine>
#include <QCursor>
#include <QGuiApplication>

#include "Application.hpp"

Application::Application(QObject *parent)
    :   QObject(parent),
        _settings(this),
        _backendProject(std::make_shared<Audio::Project>(Core::FlatString(DefaultProjectName))),
        _scheduler(Audio::ProjectPtr(_backendProject), this),
        _project(_backendProject.get(), this)
{
    _Instance = this;
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}


void Application::setCursorVisibility(bool visible) const noexcept
{
    if (visible)
        qApp->restoreOverrideCursor();
    else
        qApp->setOverrideCursor(QCursor(Qt::BlankCursor));
}

void Application::setCursorPos(const QPoint &pos) const noexcept
{
    QCursor::setPos(pos);
}