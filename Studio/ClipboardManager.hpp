/**
 * @ Author: Cédric Lucchese
 * @ Description: Clipboard Manager
 */

#pragma once

#include <QGuiApplication>
#include <QClipboard>

#include "Note.hpp"
#include "PartitionInstance.hpp"
#include "PartitionModel.hpp"
#include "NodeModel.hpp"

/** @brief Manage the clipboard to the qml */
class ClipboardManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(State state READ state WRITE setState NOTIFY stateChanged)
    Q_PROPERTY(int count READ count WRITE setCount NOTIFY countChanged)
    Q_PROPERTY(NodeModel *partitionInstanceNode READ partitionInstanceNode WRITE setPartitionInstanceNode NOTIFY partitionInstanceNodeChanged)

public:

    enum class State : int {
        Nothing = 0,
        Note,
        Partition
    };
    Q_ENUM(State)

    /** @brief Construct a new ClipboardManager */
    explicit ClipboardManager(QObject *parent = nullptr)
        : QObject(parent) {};

    /** @brief Destructor */
    ~ClipboardManager(void) override = default;

    /** @brief Get the state */
    [[nodiscard]] State state(void) const noexcept { return _state; }

    /** @brief Set the state */
    void setState(const State &state) noexcept;

    /** @brief Get the count */
    [[nodiscard]] int count(void) const noexcept { return _count; }

    /** @brief Set the count */
    void setCount(int count) noexcept;

    /** @brief Get the binded node */
    [[nodiscard]] NodeModel *partitionInstanceNode(void) const noexcept { return _partitionInstanceNode; }

    /** @brief Set the binded node */
    void setPartitionInstanceNode(NodeModel *node) noexcept;

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

    // /** @brief Clear the clipboard */
    // void clear(void) noexcept
    // {
    //     QGuiApplication::clipboard()->clear();
    // }

    /** @brief Wrapper JSON */
    QString notesToJson(const QVector<Note> &notes) noexcept;
    QVector<Note> jsonToNotes(const QString &json) const noexcept;

    /** @brief Wrapper JSON */
    QString partitionInstancesToJson(const QVector<PartitionInstance> &instances) noexcept;
    QVector<PartitionInstance> jsonToPartitionInstances(const QString &json) const noexcept;

signals:
    /** @brief Notify when state changed */
    void stateChanged(void);

    /** @brief Notify when count changed */
    void countChanged(void);

    /** @brief Notify when partitionInstanceNode changed */
    void partitionInstanceNodeChanged(void);

private:
    int _count = 0;
    State _state = State::Nothing;
    NodeModel *_partitionInstanceNode = nullptr;
};
