/**
 * @ Author: Cédric Lucchese
 * @ Description: Device implementation
 */

#include <QQmlEngine>

#include "Models.hpp"
#include "Device.hpp"

Device::Device(const Audio::Device::LogicalDescriptor &descriptor, Audio::AudioCallback &&callback, QObject *parent)
    : QObject(parent), _data(descriptor, std::move(callback))
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

void Device::setSampleRate(const SampleRate sampleRate) noexcept
{
    if (this->sampleRate() == sampleRate)
        return;
    Models::AddProtectedEvent(
        [this, sampleRate] {
            _data.setSampleRate(static_cast<Audio::SampleRate>(sampleRate));
        },
        [this] {
            emit sampleRateChanged();
        }
    );
}

void Device::setFormat(const Format format) noexcept
{
    if (this->format() == format)
        return;
    Models::AddProtectedEvent(
        [this, format] {
            _data.setFormat(static_cast<Audio::Format>(format));
        },
        [this] {
            emit formatChanged();
        }
    );
}

void Device::setChannelArrangement(const ChannelArrangement channelArrangement) noexcept
{
    if (this->channelArrangement() == channelArrangement)
        return;
    Models::AddProtectedEvent(
        [this, channelArrangement] {
            _data.setChannelArrangement(static_cast<Audio::ChannelArrangement>(channelArrangement));
        },
        [this] {
            emit channelArrangementChanged();
        }
    );
}

void Device::setMidiChannels(const MidiChannels midiChannels) noexcept
{
    if (this->midiChannels() == midiChannels)
        return;
    Models::AddProtectedEvent(
        [this, midiChannels] {
            _data.setMidiChannels(midiChannels);
        },
        [this] {
            emit midiChannelsChanged();
        }
    );
}

void Device::setBlockSize(const BlockSize blockSize) noexcept
{
    if (this->blockSize() == blockSize)
        return;
    Models::AddProtectedEvent(
        [this, blockSize] {
            _data.setBlockSize(blockSize);
        },
        [this] {
            emit blockSizeChanged();
        }
    );
}