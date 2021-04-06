/**
 * @ Author: Cédric Lucchese
 * @ Description: Scheduler
 */

inline void Scheduler::onConsumeAudioData(std::uint8_t *data, const std::size_t size) noexcept
{
    _playbackBeat += processBeatSize();
    Audio::AScheduler::ConsumeAudioData(data, size);
}

inline Beat Scheduler::getCurrentPlaybackBeat(void) const noexcept
{
    switch (playbackMode()) {
    case PlaybackMode::Production:
        return productionPlaybackBeat();
    case PlaybackMode::Live:
        return livePlaybackBeat();
    case PlaybackMode::Partition:
        return partitionPlaybackBeat();
    case PlaybackMode::OnTheFly:
        return onTheFlyPlaybackBeat();
    default:
        return Beat();
    }
}
