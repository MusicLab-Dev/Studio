/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Colored sprite manager
 */

#pragma once

#include <QObject>
#include <QImage>
#include <QTimer>
#include <QMap>
#include <QThread>

#include <Core/Vector.hpp>
#include <Core/Functor.hpp>

class ColoredSprite;

/** @brief Cache structure of a single sprite */
struct SpriteCache
{
    Q_GADGET

    Q_PROPERTY(QImage image MEMBER image)
    Q_PROPERTY(QImage lowResImage MEMBER lowResImage)
    Q_PROPERTY(quint32 frameCount MEMBER frameCount)

public:
    QImage image {};
    QImage lowResImage {};
    quint32 frameCount { 0u };
};

class ImageLoaderThread : public QThread
{
    Q_OBJECT
public:
    /** @brief Default size of the async queue */
    static constexpr std::uint32_t DefaultQueueSize = 128u;

    /** @brief Target render size for smooth scaling */
    static constexpr int TargetRenderSize = 128;


    /** @brief Load a single image file */
    [[nodiscard]] static SpriteCache Load(const QString &path);


    /** @brief Virtual destructor */
    ~ImageLoaderThread(void) override = default;

    /** @brief Object constructor */
    ImageLoaderThread(QObject *parent = nullptr);


    /** @brief Start the thread */
    void run(void) override;


    /** @brief Get a reference over the async queue */
    [[nodiscard]] auto &queue(void) noexcept { return _queue; }

    /** @brief Get a constant reference over the async queue */
    [[nodiscard]] const auto &queue(void) const noexcept { return _queue; }


    /** @brief Froce the exit of the thread */
    void forceExit(void) noexcept { _forceExit = true; }

signals:
    /** @brief Notify that an image has been loaded */
    void imageLoaded(const QString &path, const SpriteCache &cache);

private:
    Core::SPSCQueue<QString> _queue;
    std::atomic<bool> _forceExit { false };
};

/** @brief Manager that owns every sprite animation */
class ColoredSpriteManager : public QObject
{
    Q_OBJECT
public:
    /** @brief The animation tick rate in ms */
    static constexpr int TimerTickRate = 90;


    /** @brief Cache that contains notify functors */
    using LoadCache = Core::TinyVector<ColoredSprite *>;


    /** @brief Get the manager global instance */
    [[nodiscard]] static inline ColoredSpriteManager *Get(void) noexcept { return _Instance; }


    /** @brief Destructor */
    ~ColoredSpriteManager(void) override;

    /** @brief Constructor */
    ColoredSpriteManager(QObject *parent = nullptr);

    /** @brief Query an image to the manager, may start a thread */
    void query(const QString &path, ColoredSprite *instance);


    /** @brief Cancel a query from an instance */
    void cancelQuery(const QString &path, ColoredSprite *instance);


    /** @brief Register a sprite for playback */
    void registerSprite(void) noexcept;

    /** @brief Unregister a sprite from playback */
    void unregisterSprite(void) noexcept;

signals:
    /** @brief Notify that the animation has ticked */
    void animationTick(void);

    /** @brief Notify that an image has been loaded */
    void imageLoaded(const QString &path, const SpriteCache &cache);

private:
    QMap<QString, SpriteCache> _table {};
    QMap<QString, LoadCache> _loadTable {};
    QTimer _timer {};
    quint32 _playCount { 0 };
    ImageLoaderThread _thread;

    static inline ColoredSpriteManager *_Instance { nullptr };


    /** @brief Callback when image is loaded from loader thread */
    void onImageLoaded(const QString &path, const SpriteCache &image);

    /** @brief Callback when image loader thread has finished running */
    void onThreadFinished(void);
};
