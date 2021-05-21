/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Partition preview
 */

#include <numeric>

#include <QPainter>

#include "PartitionPreview.hpp"
#include "PartitionModel.hpp"

PartitionPreview::PartitionPreview(QObject *parent)
    : QObject(parent)
{

}

void PartitionPreview::setTarget(PartitionModel *target) noexcept
{
    if (target == _target)
        return;
    _target = target;
    emit targetChanged();
    if (_target)
        invalidatePreview();
}

void PartitionPreview::invalidatePreview(void)
{
    if (!_target || _target->audioPartition()->notes().empty()) {
        _pixmap = QPixmap();
        emit previewInvalidated();
        return;
    }

    const auto &notes = _target->audioPartition()->notes();
    const int maxBeat = static_cast<int>(notes.back().range.to);
    const int width = static_cast<int>(maxBeat);
    const int height = 127 * 2;

    if (maxBeat != _pixmap.width())
        _pixmap = QPixmap(width, height);
    _pixmap.fill(QColorConstants::Transparent);

    QPainter painter(&_pixmap);

    // painter.fillRect(0, 0, width, height, QColorConstants::Red);

    // painter.fillRect(0, 69, width, 2, QColorConstants::White);

    for (const auto &note : notes) {
        painter.fillRect(
            static_cast<int>(note.range.from),
            static_cast<int>(note.key) * 2,
            static_cast<int>(note.range.to - note.range.from),
            2,
            QColorConstants::White
        );
    }

    emit previewInvalidated();
}
