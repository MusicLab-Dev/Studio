/**
 * @ Author: Pierre Veysseyre
 * @ Description: Partition Instance
 */

#pragma once

#include <QObject>

#include <Audio/PartitionInstance.hpp>

#include "Base.hpp"

struct PartitionInstance : public Audio::PartitionInstance
{
    Q_GADGET

    Q_PROPERTY(quint32 partitionIndex MEMBER partitionIndex)
    Q_PROPERTY(Beat offset MEMBER offset)
    Q_PROPERTY(BeatRange range MEMBER range)

public:
    using Audio::PartitionInstance::PartitionInstance;
    using Audio::PartitionInstance::operator=;
    using Audio::PartitionInstance::operator==;
    using Audio::PartitionInstance::operator!=;
    using Audio::PartitionInstance::operator<;
    using Audio::PartitionInstance::operator>;
    using Audio::PartitionInstance::operator<=;
    using Audio::PartitionInstance::operator>=;

    template<typename ...Args>
    PartitionInstance(Args &&...args) noexcept : Audio::PartitionInstance({ std::forward<Args>(args)... }) {}
};

Q_DECLARE_METATYPE(PartitionInstance)
