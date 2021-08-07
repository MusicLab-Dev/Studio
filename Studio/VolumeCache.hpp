/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: VolumeCache structure
 */

#pragma once

#include <QObject>

#include <Audio/Buffer.hpp>

#include "Base.hpp"

struct VolumeCache : public Audio::BufferVolumeCache
{
    Q_GADGET

    Q_PROPERTY(DB peak MEMBER peak)
    Q_PROPERTY(DB rms MEMBER rms)

public:
    using Audio::BufferVolumeCache::BufferVolumeCache;

    template<typename ...Args>
    VolumeCache(Args &&...args) noexcept : Audio::BufferVolumeCache({ std::forward<Args>(args)... }) {}
};

Q_DECLARE_METATYPE(VolumeCache)