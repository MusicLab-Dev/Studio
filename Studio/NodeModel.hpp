/**
 * @ Author: Cédric Lucchese
 * @ Description: Node Model class
 */

#pragma once

#include <QAbstractListModel>
#include <QColor>

#include <Core/FlatVector.hpp>
#include <Core/UniqueAlloc.hpp>

#include <Audio/Node.hpp>

#include "PartitionsModel.hpp"
#include "ControlsModel.hpp"
//#include "ConnectionsModel.hpp"

class NodeModel;

struct NodeWrapper
{
    Q_GADGET

    Q_PROPERTY(NodeModel *instance MEMBER instance)
public:

    NodeModel *instance { nullptr };
};

Q_DECLARE_METATYPE(NodeWrapper)

/** @brief Abstraction of a project node */
class NodeModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(NodeModel *parentNode READ parentNode NOTIFY parentNodeChanged)
    Q_PROPERTY(bool muted READ muted WRITE setMuted NOTIFY mutedChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
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
        NodeInstance = Qt::UserRole + 1
    };


    /** @brief Default constructor */
    explicit NodeModel(Audio::Node *node, QObject *parent = nullptr) noexcept;

    /** @brief Virtual destructor */
    ~NodeModel(void) noexcept override = default;

    /** @brief Get the parent node if it exists */
    [[nodiscard]] NodeModel *parentNode(void) noexcept
        { return qobject_cast<NodeModel *>(parent()); }


    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

    /** @brief Get an element from the list */
    [[nodiscard]] NodeModel *get(const int index)
        { return const_cast<NodeModel *>(const_cast<const NodeModel *>(this)->get(index)); }
    [[nodiscard]] const NodeModel *get(const int index) const;


    /** @brief Get if the node is muted */
    [[nodiscard]] bool muted(void) const noexcept { return _data->muted(); }

    /** @brief Set if the node is muted */
    void setMuted(const bool muted);


    /** @brief Get the node's color */
    [[nodiscard]] QColor color(void) noexcept { return QColor(static_cast<QRgb>(_data->color())); }

    /** @brief Set the node's color */
    void setColor(const QColor &color);


    /** @brief Get the node's name */
    [[nodiscard]] QString name(void) const noexcept
        { return QString::fromLocal8Bit(_data->name().data(), _data->name().size()); }

    /** @brief Set the node's name */
    void setName(const QString &name);


    /** @brief Get the partitions model */
    [[nodiscard]] PartitionsModel *partitions(void) noexcept { return _partitions.get(); }

    /** @brief Get the controls model */
    [[nodiscard]] ControlsModel *controls(void) noexcept { return _controls.get(); }

    /** @brief Get the connections model */
    //[[nodiscard]] ConnectionsModel *connections(void) const noexcept { return _connections; }


    /** @brief Get the flags */
    [[nodiscard]] Audio::IPlugin::Flags getFlags(void) const noexcept { return _data->flags(); }


public slots:
    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return static_cast<int>(_children.size()); }

    /** @brief Add a new node in children vector using a plugin path */
    void add(const QString &pluginPath);

    /** @brief Remove a children node */
    void remove(const int index);

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

    /** @brief Notify that the parent node has changed */
    void parentNodeChanged(void);

private:
    Audio::Node *_data { nullptr };
    Core::FlatVector<NodePtr> _children {};
    PartitionsPtr _partitions { nullptr };
    ControlsPtr _controls { nullptr };
    // PluginPtr _plugin { nullptr };
    //ConnectionsPtr _connections {};

};