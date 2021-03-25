/**
 * @ Author: Cédric Lucchese
 * @ Description: Device implementation
 */

#include <QQmlEngine>

#include "Device.hpp"

Device::Device(const Audio::Device::SDLDescriptor &descriptor, Audio::AudioCallback &&callback, QObject *parent)
    : QObject(parent), _data(descriptor, std::move(callback))
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

bool Device::setSampleRate(const quint32 sampleRate) noexcept
{
    if (!_data.setSampleRate(sampleRate))
        return false;
    emit sampleRateChanged();
    return true;
}

bool Device::setFormat(const Format format) noexcept
{
    if (!_data.setFormat(static_cast<Audio::Format>(format)))
        return false;
    emit formatChanged();
    return true;
}

bool Device::setChannelArrangement(const ChannelArrangement channelArrangement) noexcept
{
    if (!_data.setChannelArrangement(static_cast<Audio::ChannelArrangement>(channelArrangement)))
        return false;
    emit channelArrangementChanged();
    return true;
}

bool Device::setMidiChannels(const quint16 midiChannels) noexcept
{
    if (!_data.setMidiChannels(midiChannels))
        return false;
    emit midiChannelsChanged();
    return true;
}

bool Device::setBlockSize(const quint16 blockSize) noexcept
{
    if (!_data.setBlockSize(blockSize))
        return false;
    emit blockSizeChanged();
    return true;
}