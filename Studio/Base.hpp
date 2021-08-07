/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio base
 */

#pragma once

#include <QObject>
#include <QDebug>

#include <Audio/Base.hpp>

using ParamID = Audio::ParamID;
using ParamValue = Audio::ParamValue;
using Beat = Audio::Beat;
using Key = Audio::Key;
using Velocity = Audio::Velocity;
using Tuning = Audio::Tuning;
using DB = Audio::DB;
using BPM = Audio::BPM;
using MidiChannels = Audio::MidiChannels;
using BlockSize = Audio::BlockSize;
using SampleRate = Audio::SampleRate;

struct BeatRange : public Audio::BeatRange
{
    Q_GADGET

    Q_PROPERTY(Beat from MEMBER from)
    Q_PROPERTY(Beat to MEMBER to)

public:
    using Audio::BeatRange::BeatRange;
    using Audio::BeatRange::operator=;
    using Audio::BeatRange::operator+=;

    template<typename ...Args>
    BeatRange(Args &&...args) noexcept : Audio::BeatRange({ std::forward<Args>(args)... }) {}
};

Q_DECLARE_METATYPE(BeatRange)
