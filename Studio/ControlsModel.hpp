/**
 * @ Author: Gonzalez Dorian
 * @ Description: Controls Model class
 */

#pragma once

#include <vector>

#include <QObject>
#include <QAbstractListModel>

#include <MLCore/Utils.hpp>
#include <MLAudio/Base.hpp>

/** @brief Exposes a list of audio controls */
class ControlsModel : public QAbstractListModel
{
    Q_OBJECT

public:
    /** @brief Roles of each Controls */
    enum class Roles {
        Control = Qt::UserRole + 1
    };

    /** @brief Default constructor */
    explicit ControlsModel(QObject *parent, Audio::Controls *controls) noexcept;

    /** @brief Destruct the ControlsModel */
    ~ControlsModel(void) noexcept = default;

    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return  _data->size(); }
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

    /** @brief Get the index controlModel */
    [[nodiscard]] ControlModel *get(const int index) noexcept_ndebug { return const_cast<ControlModel *>(std::as_const(this)->get(index)); }
    [[nodiscard]] const ControlModel *get(const int index) const noexcept_ndebug;

public slots:
    /** @brief Move Control from to */
    void move(const int from, const int to);

public /* slots */:
    /** @brief Add a children to the list */
    Q_INVOKABLE void add(const Audio::ParamID paramID) noexcept_ndebug;

    /** @brief Remove a children from the list */
    Q_INVOKABLE void remove(const int index) noexcept_ndebug;

private:
    Audio::Controls *_data { nullptr };
    std::vector<UniqueAlloc<ControlModel>> _controls;

    /** @brief Refresh internal models */
    void refreshControls(void);
}