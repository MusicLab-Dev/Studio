/**
 * @ Author: Cédric Lucchese
 * @ Description: Device implementation
 */

#include <QQmlEngine>
#include <QDebug>

#include "Models.hpp"
#include "Device.hpp"

Device::Device(const Audio::Device::LogicalDescriptor &descriptor, Audio::AudioCallback &&callback, QObject *parent)
    : QObject(parent), _data(descriptor, std::move(callback))
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);

    auto n = name();
    if (n.isEmpty())
        n = Audio::Device::DefaultDeviceName;
    qDebug().nospace() << "Acquired audio device:"
        << "\n\tname: " << n
        << "\n\tsampleRate: " << sampleRate()
        << "\n\tformat: " << format()
        << "\n\tblockSize: " << blockSize()
        << "\n\tchannelArrangement: " << channelArrangement()
        << "\n\tmidiChannels: " << midiChannels();
}

void Device::setLogicalDescriptor(const Audio::Device::LogicalDescriptor &descriptor) noexcept
{
    _data.setLogicalDescriptor(descriptor);
    _data.reloadDevice();
    emit nameChanged();
    emit sampleRateChanged();
    emit formatChanged();
    emit channelArrangementChanged();
    emit midiChannelsChanged();
    emit blockSizeChanged();
}

void Device::setName(const QString &name) noexcept
{
    Core::TinyString n = name.toStdString();
    if (_data.name() == n)
        return;
    _data.setName(n);
    _data.reloadDevice();
    emit nameChanged();
}
