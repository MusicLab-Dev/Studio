/**
 * @ Author: Cédric Lucchese
 * @ Description: Main Application implementation
 */

#include <QQmlEngine>
#include <QCursor>
#include <QGuiApplication>

#include "Studio.hpp"
#include "Application.hpp"

Application::Application(QObject *parent)
    :   QObject(parent),
        _settings(this),
        _translator(),
        _backendProject(std::make_shared<Audio::Project>(Core::FlatString(DefaultProjectName))),
        _scheduler(Audio::ProjectPtr(_backendProject), this),
        _project(_backendProject.get(), this)
{
    _Instance = this;
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
    updateTranslations();
}

void Application::updateTranslations(void)
{
    const QString filename = _settings.getDefault("language", "English").toString();

    std::cout << "Application: Changing language to " << filename.toStdString() << std::endl;

    if (_translator) {
        QCoreApplication::removeTranslator(_translator.get());
        _translator.reset();
    }
    _translator = std::make_unique<QTranslator>(this);

    if (_translator->load(filename, ":/Translations")) {
        QCoreApplication::installTranslator(_translator.get());
        reinterpret_cast<Studio *>(qApp)->qmlEngine()->retranslate();
    } else {
        std::cout << "Application: Translator install failed" << std::endl;
        _translator.reset();
    }
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
