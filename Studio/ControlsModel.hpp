/**
 * @ Author: Gonzalez Dorian
 * @ Description: Controls Model class
 */

#pragma once

#include <vector>
#include <utility>

#include <QAbstractListModel>

#include <Audio/Control.hpp>
#include <Audio/Controls.hpp>

#include "ControlModel.hpp"

class NodeModel;

/** @brief Exposes a list of audio controls */
class ControlsModel : public QAbstractListModel
{
    Q_OBJECT

public:
    /** @brief Roles of each Controls */
    enum class Roles : int {
        Control = Qt::UserRole + 1
    };

    /** @brief Default constructor */
    explicit ControlsModel(Audio::Controls *controls, NodeModel *parent = nullptr) noexcept;

    /** @brief Virtual destructor */
    ~ControlsModel(void) noexcept override = default;

    /** @brief Get the parent node if it exists */
    [[nodiscard]] NodeModel *parentNode(void) noexcept
        { return reinterpret_cast<NodeModel *>(parent()); }


    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

    /** @brief Get the index controlModel */
    [[nodiscard]] ControlModel *get(const int index) noexcept_ndebug
        { return const_cast<ControlModel *>(const_cast<const ControlsModel *>(this)->get(index)); }
    [[nodiscard]] const ControlModel *get(const int index) const noexcept_ndebug;


    /** @brief Get underlying audio controls */
    [[nodiscard]] Audio::Controls *audioControls(void) noexcept { return _data; }
    [[nodiscard]] const Audio::Controls *audioControls(void) const noexcept { return _data; }

public slots:
    /** @brief Return the count of element in the model */
    int count(void) const noexcept { return static_cast<int>(_controls.size()); }

    /** @brief Add a children to the list */
    void add(const ParamID paramID);

    /** @brief Remove a children from the list */
    void remove(const int index);

    /** @brief Move Control from to */
    void move(const int from, const int to);

    /** @brief Get a single control model */
    ControlModel *getControl(const int index) { return get(index); }

public: // Allow external insert / remove
    using QAbstractListModel::beginRemoveRows;
    using QAbstractListModel::endRemoveRows;
    using QAbstractListModel::beginInsertRows;
    using QAbstractListModel::endInsertRows;

private:
    Audio::Controls *_data { nullptr };
    Core::Vector<Core::UniqueAlloc<ControlModel>> _controls;

    /** @brief Refresh internal models */
    void refreshControls(void);
};
