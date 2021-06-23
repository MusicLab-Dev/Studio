/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Partition preview instance
 */

#include <numeric>

#include <QPainter>

#include "PartitionPreview.hpp"
#include "PartitionModel.hpp"

PartitionPreview::PartitionPreview(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
}

void PartitionPreview::setTarget(PartitionModel *target)
{
    if (target == _target)
        return;
    if (_target)
        disconnect(_target, &PartitionModel::notesChanged, this, &PartitionPreview::requestUpdate);
    _target = target;
    if (_target)
        connect(_target, &PartitionModel::notesChanged, this, &PartitionPreview::requestUpdate);
    emit targetChanged();
    requestUpdate();
}

void PartitionPreview::setRange(const BeatRange &range)
{
    if (_range.from == range.from && _range.to == range.to)
        return;
    _range = range;
    emit rangeChanged();
}

void PartitionPreview::paint(QPainter *painter)
{
    constexpr int NotesPerOctave = 12;

    if (!_target || _target->audioPartition()->notes().empty()) {
        // painter->fillRect(0, 0, static_cast<int>(width()), static_cast<int>(height()), QColorConstants::Transparent);
        return;
    }

    const auto &notes = _target->audioPartition()->notes();

    // Find the key range
    Audio::Key minKey = std::numeric_limits<Audio::Key>::max();
    Audio::Key maxKey = 0u;
    for (const auto &note : notes) {
        minKey = std::min(minKey, note.key);
        maxKey = std::max(maxKey, note.key);
    }
    const int arrangedMinKey = static_cast<int>(minKey) - (static_cast<int>(minKey) % NotesPerOctave);
    const int arrangedMaxKey = static_cast<int>(maxKey) + (NotesPerOctave - (static_cast<int>(maxKey) % NotesPerOctave));
    const int rangeKey = arrangedMaxKey - arrangedMinKey;

    // Deduce note height
    const qreal realNoteHeight = height() / static_cast<qreal>(rangeKey);
    const int noteHeight = std::max(static_cast<int>(realNoteHeight), 1);

    // Cached computations
    const QColor color(255, 255, 255, 200);
    const QColor borderColor(127, 127, 127, 200);
    const int fixedWidth = static_cast<int>(width());
    const int fixedHeight = static_cast<int>(height()) - noteHeight;
    const qreal pixelsPerBeatPrecision = width() / static_cast<qreal>(_range.to - _range.from);
    QRect rect;

    // Draw each visible note
    painter->setPen(borderColor);
    for (const auto &note : notes) {
        rect.setX(static_cast<int>(static_cast<qreal>(note.range.from) * pixelsPerBeatPrecision));
        rect.setY(fixedHeight - static_cast<int>(static_cast<qreal>(note.key - arrangedMinKey) * realNoteHeight));
        rect.setWidth(static_cast<int>(static_cast<qreal>(note.range.to - note.range.from) * pixelsPerBeatPrecision));
        rect.setHeight(noteHeight);
        if (rect.x() > fixedWidth)
            return;
        painter->fillRect(rect, color);
        if (noteHeight < 3) {
            painter->drawLine(QLine(rect.left(), rect.y(), rect.x(), rect.bottom()));
            painter->drawLine(QLine(rect.right(), rect.y(), rect.right(), rect.bottom()));
        } else {
            painter->drawRect(rect);
        }
    }
}