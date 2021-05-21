/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Partition preview instance
 */

#include <QPainter>

#include "PartitionPreviewInstance.hpp"
#include "PartitionPreview.hpp"

PartitionPreviewInstance::PartitionPreviewInstance(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
}

void PartitionPreviewInstance::setSource(PartitionPreview *source)
{
    if (source == _source)
        return;
    if (_source)
        disconnect(_source, &PartitionPreview::previewInvalidated, this, &PartitionPreviewInstance::requestUpdate);
    _source = source;
    if (_source)
        connect(_source, &PartitionPreview::previewInvalidated, this, &PartitionPreviewInstance::requestUpdate);
    emit sourceChanged();
    requestUpdate();
}

void PartitionPreviewInstance::setRange(const BeatRange &range)
{
    if (_range.from == range.from && _range.to == range.to)
        return;
    _range = range;
    emit rangeChanged();
}

void PartitionPreviewInstance::paint(QPainter *painter)
{
    if (!_source || !isVisible())
        return;
    const auto ratio = width() / static_cast<qreal>(_range.to - _range.from);
    const auto &pixmap = source()->pixmap();
    const auto w = static_cast<int>(ratio * static_cast<qreal>(pixmap.width()));

    painter->drawPixmap(0, 0, w, static_cast<int>(height()), pixmap);
}