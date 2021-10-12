/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Partition preview instance
 */

inline void ProjectPreview::collectInstances(const NodeModel *node) noexcept
{
    const auto &color = node->color();
    const auto &instances = *node->partitions()->instances()->audioInstances();

    if (!instances.empty()) {
        for (const auto &instance : instances) {
            _data.push(PaintData {
                color,
                _currentY,
                instance.range
            });
        }
        ++_currentY;
    }
}
