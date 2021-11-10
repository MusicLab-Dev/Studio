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
    Q_PROPERTY(QColor foregroundColor READ foregroundColor NOTIFY foregroundColorChanged)
    Q_PROPERTY(QColor contentColor READ contentColor NOTIFY contentColorChanged)
    Q_PROPERTY(QColor panelColor READ panelColor NOTIFY panelColorChanged)
    Q_PROPERTY(QColor backgroundColor READ backgroundColor NOTIFY backgroundColorChanged)
    Q_PROPERTY(QColor accentColor READ accentColor NOTIFY accentColorChanged)
    Q_PROPERTY(QColor timelineColor READ timelineColor NOTIFY timelineColorChanged)
    Q_PROPERTY(QColor disabledColor READ disabledColor NOTIFY disabledColorChanged)

public:
    /** @brief Preconfigured themes */
    enum class Theme {
        Classic,
        Dark
    };
    Q_ENUM(Theme)

    /** @brief Preconfigured sub-color chains */
    enum class SubChain {
        Red,
        Green,
        Blue,
        Total
    };
    Q_ENUM(SubChain)


    /** @brief Get a color from color chain using an index (index %= colorChainCount) */
    [[nodiscard]] static QColor GetColorFromChain(const quint32 index) noexcept;

    /** @brief Get a color from a color sub-chain using an index (index %= colorSubChainCount) */
    [[nodiscard]] static QColor GetColorFromSubChain(const SubChain subChain, const quint32 index) noexcept;


    /** @brief Construct a theme manager */
    ThemeManager(QObject *parent = nullptr);

    /** @brief Construct a theme manager */
    virtual ~ThemeManager(void) = default;


    /** @brief Get / Set current theme */
    [[nodiscard]] Theme theme(void) const noexcept { return _theme; }
    void setTheme(const Theme theme);


    /** @brief Color getters */
    [[nodiscard]] QColor foregroundColor(void) const noexcept { return _foregroundColor; }
    [[nodiscard]] QColor contentColor(void) const noexcept { return _contentColor; }
    [[nodiscard]] QColor backgroundColor(void) const noexcept { return _backgroundColor; }
    [[nodiscard]] QColor panelColor(void) const noexcept { return _panelColor; }
    [[nodiscard]] QColor accentColor(void) const noexcept { return _accentColor; }
    [[nodiscard]] QColor timelineColor(void) const noexcept { return _timelineColor; }
    [[nodiscard]] QColor disabledColor(void) const noexcept { return _disabledColor; }

public slots:
    /** @brief Get a color from color chain using an index (index %= colorChainCount) */
    QColor getColorFromChain(const quint32 index) noexcept { return GetColorFromChain(index); }

    /** @brief Get a color from color sub-chain using an index (index %= colorSubChainCount) */
    QColor getColorFromSubChain(const SubChain subChain, const quint32 index) noexcept { return GetColorFromSubChain(subChain, index); }

signals:
    /** @brief Notify that theme has changed */
    void themeChanged(void);

    /** @brief Notify that a color changed */
    void foregroundColorChanged(void);
    void contentColorChanged(void);
    void backgroundColorChanged(void);
    void panelColorChanged(void);
    void accentColorChanged(void);
    void timelineColorChanged(void);
    void disabledColorChanged(void);

private:
    Theme _theme { Theme::Classic };
    QColor _foregroundColor {};
    QColor _contentColor {};
    QColor _backgroundColor {};
    QColor _panelColor {};
    QColor _accentColor {};
    QColor _timelineColor {};
    QColor _disabledColor {};

    /** @brief Update colors */
    void updateThemeColors(void);
};
