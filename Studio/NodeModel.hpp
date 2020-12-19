/**
 * @ Author: Cédric Lucchese
 * @ Description: Node Model class
 */

#pragma once

#include <QObject>
#include <QAbstractListModel>

#include <Core/FlatVector.hpp>
#include <Core/Utils.hpp>
#include <Core/UniqueAlloc.hpp>

#include <Audio/Node.hpp>

#include "PartitionsModel.hpp"
#include "ControlsModel.hpp"
//#include "ConnectionsModel.hpp"

/** @brief Abstraction of a project node */
class alignas(64) NodeModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(bool muted READ muted WRITE setMuted NOTIFY mutedChanged)
    //Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(PartitionsModel *partitions READ partitions NOTIFY partitionsChanged)
    Q_PROPERTY(ControlsModel *controls READ controls NOTIFY controlsChanged)
    //Q_PROPERTY(ConnectionsModel *connections READ connections NOTIFY connectionsChanged)

public:
    /** @brief Pointer to a node model */
    using NodePtr = Core::UniqueAlloc<NodeModel>;

    /** @brief Pointer to a partition model */
    using PartitionsPtr = Core::UniqueAlloc<PartitionsModel>;

    /** @brief Pointer to a controls model */
    using ControlsPtr = Core::UniqueAlloc<ControlsModel>;

    /** @brief Pointer to connections model */
    //using ConnectionsPtr = Core::UniqueAlloc<ConnectionsModel>;

    /** @brief Roles of each instance */
    enum class Roles : int {
        Node = Qt::UserRole + 1
    };

    /** @brief Default constructor */
    explicit NodeModel(Audio::Node *node, QObject *parent = nullptr) noexcept;

    /** @brief Destruct the instance */
    ~NodeModel(void) noexcept = default;


    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return 1; }
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

    [[nodiscard]] const NodeModel *get(const int index) const;


    /** @brief Get if the node is muted */
    [[nodiscard]] bool muted(void) const noexcept { return _data->muted(); }

    /** @brief Set if the node is muted */
    bool setMuted(bool muted) noexcept;


    /** @brief Get the node's color */
    //[[nodiscard]] QColor color(void) const noexcept { return /*_data->color()*/QColor(Qt::GlobalColor::black); }

    /** @brief Set the node's color */
    bool setColor(const QColor &color) noexcept;


    /** @brief Get the node's name */
    [[nodiscard]] QString name(void) const noexcept { return _data->name().data(); }

    /** @brief Set the node's name */
    bool setName(const QString &name) noexcept;


    /** @brief Get the partitions model */
    [[nodiscard]] PartitionsModel *partitions(void) noexcept { return _partitions.get(); }

    /** @brief Get the controls model */
    [[nodiscard]] ControlsModel *controls(void) noexcept { return _controls.get(); }

    /** @brief Get the connections model */
    //[[nodiscard]] ConnectionsModel *connections(void) const noexcept { return _connections; }


    /** @brief Get the flags */
    [[nodiscard]] Audio::IPlugin::Flags getFlags(void) const noexcept { return _data->flags(); }

signals:
    /** @brief Notify that muted property has changed */
    void mutedChanged(void);

    /** @brief Notify that color property has changed */
    void colorChanged(void);

    /** @brief Notify that name property has changed */
    void nameChanged(void);

    /** @brief Notify that partitions property has changed */
    void partitionsChanged(void);

    /** @brief Notify that controls property has changed */
    void controlsChanged(void);

    /** @brief Notify that connections property has changed */
    void connectionsChanged(void);

private:
    Audio::Node *_data { nullptr };
    Core::FlatVector<NodePtr> _children {};
    PartitionsPtr _partitions { nullptr };
    ControlsPtr _controls { nullptr };
    //ConnectionsPtr _connections {};
};