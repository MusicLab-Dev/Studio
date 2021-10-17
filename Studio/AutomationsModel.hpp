/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Automations Model class
 */

#pragma once

#include <vector>
#include <utility>

#include <QAbstractListModel>

#include <Audio/Automations.hpp>

#include "AutomationModel.hpp"

class NodeModel;

using AutomationPtr = Core::UniqueAlloc<AutomationModel>;

/** @brief Exposes a list of audio automations */
class AutomationsModel : public QAbstractListModel
{
    Q_OBJECT

public:
    /** @brief Roles of each Automations */
    enum class Roles : int {
        Automation = Qt::UserRole + 1
    };

    /** @brief Default constructor */
    explicit AutomationsModel(Audio::Automations *automations, NodeModel *parent = nullptr) noexcept;

    /** @brief Virtual destructor */
    ~AutomationsModel(void) noexcept override = default;

    /** @brief Get the parent node if it exists */
    [[nodiscard]] NodeModel *parentNode(void) noexcept
        { return reinterpret_cast<NodeModel *>(parent()); }


    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

    /** @brief Get the AutomationModel at index */
    [[nodiscard]] AutomationModel *get(const int index) noexcept_ndebug
        { return const_cast<AutomationModel *>(const_cast<const AutomationsModel *>(this)->get(index)); }
    [[nodiscard]] const AutomationModel *get(const int index) const noexcept_ndebug;


    /** @brief Get underlying audio automations */
    [[nodiscard]] Audio::Automations *audioAutomations(void) noexcept { return _data; }
    [[nodiscard]] const Audio::Automations *audioAutomations(void) const noexcept { return _data; }

public slots:
    /** @brief Return the count of element in the model */
    int count(void) const noexcept { return static_cast<int>(_automations.size()); }

    /** @brief Get a single automation model */
    AutomationModel *getAutomation(const int index) { return get(index); }

public: // Allow external insert / remove
    using QAbstractListModel::beginRemoveRows;
    using QAbstractListModel::endRemoveRows;
    using QAbstractListModel::beginInsertRows;
    using QAbstractListModel::endInsertRows;

private:
    Audio::Automations *_data { nullptr };
    Core::TinyVector<AutomationPtr> _automations;

    /** @brief Refresh internal models */
    void refreshAutomations(void);
};
