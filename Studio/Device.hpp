/**
 * @ Author: Cédric Lucchese
 * @ Description: Device class
 */

#pragma once

#include <QObject>

#include <Audio/Device.hpp>

#include "Base.hpp"

/** @brief Device class */
class Device : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(SampleRate sampleRate READ sampleRate WRITE setSampleRate NOTIFY sampleRateChanged)
    Q_PROPERTY(Format format READ format WRITE setFormat NOTIFY formatChanged)
    Q_PROPERTY(ChannelArrangement channelArrangement READ channelArrangement WRITE setChannelArrangement NOTIFY channelArrangementChanged)
    Q_PROPERTY(MidiChannels midiChannels READ midiChannels WRITE setMidiChannels NOTIFY midiChannelsChanged)
    Q_PROPERTY(BlockSize blockSize READ blockSize WRITE setBlockSize NOTIFY blockSizeChanged)

public:
    enum class Format : int {
        Unknown = static_cast<int>(Audio::Format::Unknown),
        Fixed8 = static_cast<int>(Audio::Format::Fixed8),
        Fixed16 = static_cast<int>(Audio::Format::Fixed16),
        Fixed32 = static_cast<int>(Audio::Format::Fixed32),
        Floating32 = static_cast<int>(Audio::Format::Floating32)
    };
    Q_ENUM(Format)

    enum class ChannelArrangement : int {
        Mono = static_cast<int>(Audio::ChannelArrangement::Mono),
        Stereo = static_cast<int>(Audio::ChannelArrangement::Stereo)
    };
    Q_ENUM(ChannelArrangement)


    /** @brief Default constructor */
    explicit Device(const Audio::Device::LogicalDescriptor &descriptor, Audio::AudioCallback &&callback, QObject *parent = nullptr);

    /** @brief Destruct the instance */
    ~Device(void) noexcept = default;


    /** @brief Get the name property */
    [[nodiscard]] QString name(void) const noexcept
        { return QString::fromLocal8Bit(_data.name().data(), static_cast<int>(_data.name().size())); }

    /** @brief Set the device name (reload device) */
    void setName(const QString &name);


    /** @brief Get the sample rate */
    [[nodiscard]] SampleRate sampleRate(void) const noexcept { return _data.sampleRate(); }

    /** @brief SET the sample rate */
    void setSampleRate(const SampleRate sampleRate) noexcept;


    /** @brief Get the format */
    [[nodiscard]] Format format(void) const noexcept { return static_cast<Format>(_data.format()); }

    /** @brief Set the format */
    void setFormat(const Format format) noexcept;


    /** @brief Get the channels */
    [[nodiscard]] ChannelArrangement channelArrangement(void) const noexcept { return static_cast<ChannelArrangement>(_data.channelArrangement()); }

    /** @brief Set the channels */
    void setChannelArrangement(const ChannelArrangement channels) noexcept;


    /** @brief Get the record */
    [[nodiscard]] MidiChannels midiChannels(void) const noexcept { return _data.midiChannels(); }

    /** @brief Set the record */
    void setMidiChannels(const MidiChannels midiChannels) noexcept;


    /** @brief Get the record */
    [[nodiscard]] BlockSize blockSize(void) const noexcept { return _data.blockSize(); }

    /** @brief Set the record */
    void setBlockSize(const BlockSize blockSize) noexcept;


    /** @brief Register the audio callback */
    void start(void) { _data.start(); }

    /** @brief Unregister the audio callback */
    void stop(void) { _data.stop(); }

    [[nodiscard]] Audio::Device *audioDevice(void) noexcept { return &_data; }
    [[nodiscard]] const Audio::Device *audioDevice(void) const noexcept { return &_data; }

signals:
    /** @brief Notify that name property has changed */
    void nameChanged(void);

    /** @brief Notify that sample rate property has changed */
    void sampleRateChanged(void);

    /** @brief Notify that format property has changed */
    void formatChanged(void);

    /** @brief Notify that channel arrangement property has changed */
    void channelArrangementChanged(void);

    /** @brief Notify that midi channels property has changed */
    void midiChannelsChanged(void);

    /** @brief Notify that block sized property has changed */
    void blockSizeChanged(void);

private:
    Audio::Device _data;
};
