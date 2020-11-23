/**
 * @ Author: Dorian Gonzalez
 * @ Description: PartitionsModel class
 */

#include <stdexcept>

#include "PartitionsModel.hpp"

PartitionsModel::PartitionsModel(QObject *parent) noexcept
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> PartitionsModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { Roles::Partition, "partition"}
    };
}

QVariant PartitionsModel::data(const QModelIndex &index, int role) const noexcept_ndebug
{
    coreAssert(index.row() < 0 || index.row() >= count(),
        throw std::range_error("PartitionsModel::data: Given index is not in range"));
    const auto &child = (*_data)[index.row()];
    switch (role) {
    case Roles::Partition:
        return child;
    default:
        return QVariant();
    }
}

const PartitionModel &PartitionsModel::get(const int index) const
{
    /** TODO */
}

void PartitionsModel::add(const Audio::BeatRange &range) noexcept_ndebug
{
    /** TODO */
}

void PartitionsModel::remove(const int index)
{
    /** TODO */
}

void PartitionsModel::move(const int from, const int to)
{
    /** TODO */
}