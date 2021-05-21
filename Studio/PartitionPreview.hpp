/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Partition preview
 */

#pragma once

#include <QObject>
#include <QPixmap>

class PartitionModel;

class PartitionPreview : public QObject
{
    Q_OBJECT

    Q_PROPERTY(PartitionModel *target READ target WRITE setTarget NOTIFY targetChanged)

public:
    /** @brief Constructor */
    PartitionPreview(QObject *parent = nullptr);

    /** @brief Destructor */
    ~PartitionPreview(void) = default;

    /** @brief Get / Set the target property */
    [[nodiscard]] PartitionModel *target(void) const noexcept { return _target; }
    void setTarget(PartitionModel *target) noexcept;

    /** @brief Invalidate the preview so it has to be re-computed */
    void invalidatePreview(void);

    /** @brief Get internal pixamp */
    [[nodiscard]] const QPixmap &pixmap(void) const noexcept { return _pixmap; }

signals:
    /** @brief Notify when target property changes */
    void targetChanged(void);

    /** @brief Notify that the preview has been invalidated */
    void previewInvalidated(void);

private:
    PartitionModel *_target { nullptr };
    QPixmap _pixmap {};
};