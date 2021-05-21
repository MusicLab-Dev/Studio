/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Partition preview
 */

#pragma once

#include <QQuickPaintedItem>

#include "Base.hpp"

class PartitionPreview;

class PartitionPreviewInstance : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(PartitionPreview *source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(BeatRange range READ range WRITE setRange NOTIFY rangeChanged)

public:
    /** @brief Constructor */
    PartitionPreviewInstance(QQuickItem *parent = nullptr);

    /** @brief Destructor */
    ~PartitionPreviewInstance(void) override = default;

    /** @brief Get / Set the source property */
    [[nodiscard]] PartitionPreview *source(void) const noexcept { return _source; }
    void setSource(PartitionPreview *source);

    /** @brief Get / Set the range property */
    [[nodiscard]] const BeatRange &range(void) noexcept { return _range; }
    void setRange(const BeatRange &range);

    /** @brief Draw source */
    void paint(QPainter *painter) final;

signals:
    /** @brief Notify when source property changes */
    void sourceChanged(void);

    /** @brief Notify when range property changes */
    void rangeChanged(void);

private:
    PartitionPreview *_source { nullptr };
    BeatRange _range {};
    qreal _pixelsPerBeatPrecision { 0.0 };

    /** @brief Request an update */
    void requestUpdate(void) { update(); }
};