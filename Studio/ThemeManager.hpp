/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: The theme manager
 */

#pragma once

#include <QObject>
#include <QColor>

class ThemeManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Theme theme READ theme WRITE setTheme NOTIFY themeChanged)
    Q_PROPERTY(QColor backgroundColor READ backgroundColor NOTIFY backgroundColorChanged)
    Q_PROPERTY(QColor foregroundColor READ foregroundColor NOTIFY foregroundColorChanged)
    Q_PROPERTY(QColor contentColor READ contentColor NOTIFY contentColorChanged)
    Q_PROPERTY(QColor accentColor READ accentColor NOTIFY accentColorChanged)
    Q_PROPERTY(QColor timelineColor READ timelineColor NOTIFY timelineColorChanged)

public:
    /** @brief Preconfigured themes */
    enum class Theme {
        Classic,
        Dark
    };
    Q_ENUM(Theme)


    /** @brief Get a color from color chain using an index (on overflow, index %= colorChainCount) */
    [[nodiscard]] static QColor GetColorFromChain(const quint32 index) noexcept;


    /** @brief Construct a theme manager */
    ThemeManager(QObject *parent = nullptr)
        : QObject(parent) { updateThemeColors(); }

    /** @brief Construct a theme manager */
    virtual ~ThemeManager(void) = default;


    /** @brief Get / Set current theme */
    [[nodiscard]] Theme theme(void) const noexcept { return _theme; }
    void setTheme(const Theme theme);


    /** @brief Color getters */
    [[nodiscard]] QColor backgroundColor(void) const noexcept { return _backgroundColor; }
    [[nodiscard]] QColor foregroundColor(void) const noexcept { return _foregroundColor; }
    [[nodiscard]] QColor contentColor(void) const noexcept { return _contentColor; }
    [[nodiscard]] QColor accentColor(void) const noexcept { return _accentColor; }
    [[nodiscard]] QColor timelineColor(void) const noexcept { return _timelineColor; }

public slots:
    /** @brief Get a color from color chain using an index (on overflow, index %= colorChainCount) */
    QColor getColorFromChain(const quint32 index) noexcept { return GetColorFromChain(index); }

signals:
    /** @brief Notify that theme has changed */
    void themeChanged(void);

    /** @brief Notify that a color changed */
    void backgroundColorChanged(void);
    void foregroundColorChanged(void);
    void contentColorChanged(void);
    void accentColorChanged(void);
    void timelineColorChanged(void);

private:
    Theme _theme { Theme::Classic };
    QColor _backgroundColor {};
    QColor _foregroundColor {};
    QColor _contentColor {};
    QColor _accentColor {};
    QColor _timelineColor {};

    /** @brief Update colors */
    void updateThemeColors(void);
};
