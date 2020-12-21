/**
 * @ Author: Cédric Lucchese
 * @ Description: Device implementation
 */

#include <QQmlEngine>

#include "Device.hpp"

Device::Device(Audio::Device *device, const Audio::Descriptor &descriptor, QObject *parent)
    : QObject(parent) , _data(device)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

bool Device::setSampleRate(const int sampleRate) noexcept
{
    if (!_data->setSampleRate(sampleRate))
        return false;
    emit sampleRateChanged();
    return true;
}

bool Device::setFormat(const Audio::Device::Format &format) noexcept
{
    if (!_data->setFormat(format))
        return false;
    emit formatChanged();
    return true;
}

bool Device::setChannels(const uint8 channels) noexcept
{
    if (!_data->setChannels(channels))
        return false;
    emit channelsChanged();
    return true;
}

bool Device::setSample(const uint16 sample) noexcept
{
    if (!_data->setSample(sample))
        return false;
    emit sampleChanged();
    return true;
}

