/**
 * @ Author: Dorian Gonzalez
 * @ Description: InsatancesModel class
 */

#include <stdexcept>

#include <QHash>

#include "InstancesModel.hpp"

QHash<int, QByteArray> InstancesModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { Roles::From, "from" },
        { Roles::To, "to" }
    };
}

QVariant InstancesModel::data(const QModelIndex &index, int role) const noexcept/* noexcept_ndebug*/
{
    const auto &child = get(index.row());
    switch (role) {
    case Roles::From:
        return child.from;
    case Roles::To:
        return child.to;
    default:
        return QVariant();
    }
}

const Audio::BeatRange &InstancesModel::get(const int index) const noexcept_ndebug
{
    coreAssert(index < 0 || index >= count(),
        throw std::range_error("InstancesModel::get: Given index is not in range"));
    return (*_data)[static_cast<unsigned long>(index)];
}

void InstancesModel::add(const Audio::BeatRange &range) noexcept
{
    _data->push(range);
}

void InstancesModel::remove(const int index) noexcept_ndebug
{
    coreAssert(index < 0 || index >= count(),
        throw std::range_error("InstancesModel::remove: Given index is not in range"));
    _data->erase(_data->begin() + index);
}

void InstancesModel::move(const int index, const Audio::BeatRange &range) noexcept_ndebug
{
    coreAssert(index < 0 || index >= count(),
        throw std::range_error("InstancesModel::move: Given index is not in range"));
    _data->at(static_cast<unsigned long>(index)) = range;
    //_data->sort();
}
