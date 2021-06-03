/**
 * @ Author: Cédric Lucchese
 * @ Description: Actions Manager listener
 */

#pragma once

#include <QVariant>
#include <QObject>

#include "Application.hpp"

class ActionsManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool canUndo READ canUndo NOTIFY canUndoChanged)
    Q_PROPERTY(bool canRedo READ canRedo NOTIFY canRedoChanged)

public:
    /** @brief Construct a new ActionsManager */
    explicit ActionsManager(QObject *parent = nullptr) : QObject(parent) {};

    /** @brief Destructor */
    ~ActionsManager(void) override = default;

    /** @brief Get the application property */
    [[nodiscard]] Application *application(void) const noexcept
        { return _app; }

    /** @brief Set the application property */
    void setApplication(const QString &name);

public slots:
    void undo(void) noexcept;
    void redo(void) noexcept;
    void push(const QVariantList &action) noexcept;
    QVariantList lastAction(void) noexcept;

    int size(void) { return _actions.size(); }
    bool canUndo(void) { return size() > 0; }
    bool canRedo(void) { return _index < size(); }

signals:
    void undoProcess(const QVariantList &action);
    void redoProcess(const QVariantList &action);

private:
    Application *_app;

    QVector<QVariantList> _actions;
    int _index = 0;
};
