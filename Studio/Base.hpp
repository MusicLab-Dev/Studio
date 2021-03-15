/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio base
 */

#pragma once

#include <QObject>

#include <Audio/Base.hpp>

using ParamID = Audio::ParamID;
Q_DECLARE_METATYPE(ParamID)

using Beat = Audio::Beat;
// Q_DECLARE_METATYPE(Beat)

using Key = Audio::Key;
// Q_DECLARE_METATYPE(Key);

using Velocity = Audio::Velocity;
// Q_DECLARE_METATYPE(Velocity)

using Tuning = Audio::Tuning;
// Q_DECLARE_METATYPE(Tuning)

struct BeatRange : public Audio::BeatRange
{
    Q_GADGET

    Q_PROPERTY(Beat from MEMBER from)
    Q_PROPERTY(Beat to MEMBER to)

public:
    using Audio::BeatRange::BeatRange;
    using Audio::BeatRange::operator=;
};
Q_DECLARE_METATYPE(BeatRange)