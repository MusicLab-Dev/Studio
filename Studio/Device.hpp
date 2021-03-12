/**
 * @ Author: Cédric Lucchese
 * @ Description: Device class
 */

#pragma once

#include <QObject>

#include <Audio/Device.hpp>

/** @brief Device class */
class Device : public QObject
{
    Q_OBJECT

    Q_PROPERTY(quint32 sampleRate READ sampleRate WRITE setSampleRate NOTIFY recordChanged)
    Q_PROPERTY(Format format READ format WRITE setFormat NOTIFY formatChanged)
    Q_PROPERTY(ChannelArrangement channelArrangement READ channelArrangement WRITE setChannelArrangement NOTIFY channelArrangementChanged)
    Q_PROPERTY(quint16 midiChannels READ midiChannels WRITE setMidiChannels NOTIFY midiChannelsChanged)
    Q_PROPERTY(quint16 blockSize READ blockSize WRITE setBlockSize NOTIFY blockSizeChanged)

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
    explicit Device(const Audio::Device::Descriptor &descriptor, Audio::AudioCallback &&callback, QObject *parent = nullptr);

    /** @brief Destruct the instance */
    ~Device(void) noexcept = default;


    /** @brief Get the sample rate */
    [[nodiscard]] quint32 sampleRate(void) const noexcept { return _data.sampleRate(); }

    /** @brief SET the sample rate */
    bool setSampleRate(const quint32 sampleRate) noexcept;


    /** @brief Get the format */
    [[nodiscard]] Format format(void) const noexcept { return static_cast<Format>(_data.format()); }

    /** @brief Set the format */
    bool setFormat(const Format format) noexcept;


    /** @brief Get the channels */
    [[nodiscard]] ChannelArrangement channelArrangement(void) const noexcept { return static_cast<ChannelArrangement>(_data.channelArrangement()); }

    /** @brief Set the channels */
    bool setChannelArrangement(const ChannelArrangement channels) noexcept;


    /** @brief Get the record */
    [[nodiscard]] quint16 midiChannels(void) const noexcept { return _data.midiChannels(); }

    /** @brief Set the record */
    bool setMidiChannels(const quint16 midiChannels) noexcept;


    /** @brief Get the record */
    [[nodiscard]] quint16 blockSize(void) const noexcept { return _data.blockSize(); }

    /** @brief Set the record */
    bool setBlockSize(const quint16 blockSize) noexcept;

signals:
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
