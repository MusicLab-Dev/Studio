/*
 * @ Author: Matthieu Moinvaziri
 * @ Description: PluginModel Proxy
 */

#pragma once

#include <QSortFilterProxyModel>

#include "PluginModel.hpp"

class PluginModelProxy : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    /** @brief Constructor */
    PluginModelProxy(QObject *parent = nullptr) : QSortFilterProxyModel(parent) {}

    /** @brief Destructor */
    ~PluginModelProxy(void) override = default;

public slots:
    /** @brief Adds a control index to the filter */
    void addControl(const int index);

    /** @brief Remove a control index to the filter */
    void removeControl(const int index);

signals:

private:
    QVector<int> _filterIndexes;

    /** @brief Reimplementation of the filter virtual function */
    [[nodiscard]] bool filterAcceptsRow(int sourceRow, const QModelIndex &) const override;
};
