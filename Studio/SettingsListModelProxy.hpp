/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Settings model proxy
 */

#pragma once

#include <QSortFilterProxyModel>

#include "SettingsListModel.hpp"

class SettingsListModelProxy : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    /** @brief Constructor */
    explicit SettingsListModelProxy(QObject *parent = nullptr) : QSortFilterProxyModel(parent) {
        setSourceModel(new SettingsListModel(this));
    }

    /** @brief Destructor */
    virtual ~SettingsListModelProxy(void) override = default;

private:
};