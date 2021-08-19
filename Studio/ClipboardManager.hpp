/**
 * @ Author: Cédric Lucchese
 * @ Description: Clipboard Manager
 */

#pragma once

#include <QGuiApplication>
#include <QClipboard>

#include "Note.hpp"
#include "PartitionInstance.hpp"

/** @brief Manage the clipboard to the qml */
class ClipboardManager : public QObject
{
    Q_OBJECT

public:
    /** @brief Construct a new ClipboardManager */
    explicit ClipboardManager(QObject *parent = nullptr)
        : QObject(parent) {};

    /** @brief Destructor */
    ~ClipboardManager(void) override = default;

public slots:
    /** @brief Return the clipboard data
     *   if format == true, return "{}" if the string format is wrong (not '{' at the beginning, not the '}' at the end)
     *   else, return the brut clipboard
     */
    QString paste(bool format = true) noexcept
    {
        QString text = QGuiApplication::clipboard()->text();
        return (format || (text.size() >= 2 && text[0] == '{' && text[text.size() - 1] == '}')) ? text : "{}";
    }

    /** @brief Set the clipboard data */
    void copy(const QString &data) noexcept
    {
        QGuiApplication::clipboard()->setText(data);
    }

    /** @brief Clear the clipboard */
    void clear(void) noexcept
    {
        QGuiApplication::clipboard()->clear();
    }

    /** @brief Wrapper JSON */
    QString notesToJson(const QVector<Note> &notes) const noexcept;
    QVector<Note> jsonToNotes(const QString &json) const noexcept;

    /** @brief Wrapper JSON */
    QString partitionInstancesToJson(const QVector<PartitionInstance> &instances) const noexcept;
    QVector<PartitionInstance> jsonToPartitionInstances(const QString &json) const noexcept;
};
