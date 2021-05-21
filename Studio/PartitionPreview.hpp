/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Partition preview
 */

#pragma once

#include <QQuickPaintedItem>

#include "Base.hpp"

class PartitionModel;

class PartitionPreview : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(PartitionModel *target READ target WRITE setTarget NOTIFY targetChanged)
    Q_PROPERTY(BeatRange range READ range WRITE setRange NOTIFY rangeChanged)

public:
    /** @brief Constructor */
    PartitionPreview(QQuickItem *parent = nullptr);

    /** @brief Destructor */
    ~PartitionPreview(void) override = default;

    /** @brief Get / Set the target property */
    [[nodiscard]] PartitionModel *target(void) const noexcept { return _target; }
    void setTarget(PartitionModel *target);

    /** @brief Get / Set the range property */
    [[nodiscard]] const BeatRange &range(void) noexcept { return _range; }
    void setRange(const BeatRange &range);

    /** @brief Draw target within specified range */
    void paint(QPainter *painter) final;

signals:
    /** @brief Notify when target property changes */
    void targetChanged(void);

    /** @brief Notify when range property changes */
    void rangeChanged(void);

private:
    PartitionModel *_target { nullptr };
    BeatRange _range {};

    /** @brief Request an update */
    void requestUpdate(void) { update(); }
};