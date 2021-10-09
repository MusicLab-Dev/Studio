/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Node list model
 */

#pragma once

#include <QAbstractListModel>

#include "NodeModel.hpp"

class NodeListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    /** @brief Roles of each instance */
    enum class Roles : int {
        NodeInstance = Qt::UserRole + 1
    };

    /** @brief Constructor */
    NodeListModel(QObject *parent = nullptr) : QAbstractListModel(parent) {}

    /** @brief Destructor */
    ~NodeListModel(void) override = default;


    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

public slots:
    /** @brief Return the count of element in the model */
    int count(void) const noexcept { return _models.size(); }

    /** @brief Return true if the NodeListModel has the same nodes */
    bool equals(const QVector<NodeModel *> nodes) const noexcept;

    /** @brief Get the formated name of the list */
    QString getListName(void) const noexcept;

    /** @brief Load a single node */
    void loadNode(NodeModel *node);

    /** @brief Load multiple nodes */
    void loadNodes(const QVector<NodeModel *> &models);

private:
    QVector<NodeModel *> _models;
};