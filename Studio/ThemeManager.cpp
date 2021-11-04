/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: ThemeManager
 */

#include <QQmlEngine>

#include "ThemeManager.hpp"

struct ThemePack
{
    QColor background {};
    QColor foreground {};
    QColor content {};
    QColor accent {};
    QColor timeline {};
    QColor disabled {};
};

static const ThemePack ClassicThemePack {
    /* background: */ "#FFFFFF",
    /* foreground: */ "#355079",
    /* content: */ "#FFFFFF",
    /* accent: */ "#00ECBA",
    /* timeline: */ "#31A8FF",
    /* disabled: */ "#3d3d3d"
};

static const ThemePack DarkThemePack {
    /* background: */ "#0f0f12",
    /* foreground: */ "#2E323E",
    /* content: */ "#191A1E",
    /* accent: */ "#8133FF", //QColor("#6D13FF").lighter(150),
    /* timeline: */ QColor("#8133FF").darker(150),
    /* disabled: */ "#3d3d3d"
};

ThemeManager::ThemeManager(QObject *parent)
    : QObject(parent)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
    updateThemeColors();
}

void ThemeManager::setTheme(const Theme theme)
{
    if (_theme == theme)
        return;
    _theme = theme;
    emit themeChanged();
    updateThemeColors();
}

void ThemeManager::updateThemeColors(void)
{
    const auto ApplyTheme = [this](const ThemePack &pack) {
        _foregroundColor = pack.foreground;
        _contentColor = pack.content;
        _backgroundColor = pack.background;
        _accentColor = pack.accent;
        _timelineColor = pack.timeline;
        _disabledColor = pack.disabled;
    };

    switch (theme()) {
    case Theme::Classic:
        ApplyTheme(ClassicThemePack);
        break;
    case Theme::Dark:
        ApplyTheme(DarkThemePack);
        break;
    default:
        ApplyTheme(ClassicThemePack);
        break;
    }
    emit foregroundColorChanged();
    emit contentColorChanged();
    emit backgroundColorChanged();
    emit accentColorChanged();
    emit timelineColorChanged();
    emit disabledColorChanged();
}

static const QColor ColorChain[] = {
    QColor(0xF03738), // Red
    QColor(0xFFA965), // Orange
    QColor(0xF9F871), // Yellow
    QColor(0xFF978F), // Red 2
    QColor(0x3CC13B).lighter(125), // Green
    QColor(0x42FF8E), // Green 2
    QColor(0x31E9A7), // Green 3
    QColor(0x63BAAA), // Turquoise
    QColor(0x00C5FF), // Blue
    QColor(0x00DCE7), // Cyan
    QColor(0xFF7BE2), // Pink
    QColor(0x6D13FF).lighter(150),
};

constexpr quint32 ColorChainCount = sizeof(ColorChain) / sizeof(ColorChain[0]);

QColor ThemeManager::GetColorFromChain(const quint32 index) noexcept
{
    return ColorChain[index % ColorChainCount];
}

static const QColor RedColorSubChain[] = {
    QColor(0xF03738),
    QColor(0xFFA965),
    QColor(0xF9F871),
    QColor(0xFF978F),

};

constexpr quint32 RedColorSubChainCount = sizeof(RedColorSubChain) / sizeof(RedColorSubChain[0]);

static const QColor GreenColorSubChain[] = {
    QColor(0x3CC13B).lighter(125),
    QColor(0x42FF8E),
    QColor(0x31E9A7),
    QColor(0x63BAAA),
};

constexpr quint32 GreenColorSubChainCount = sizeof(GreenColorSubChain) / sizeof(GreenColorSubChain[0]);

static const QColor BlueColorSubChain[] = {
    QColor(0x00C5FF),
    QColor(0x00DCE7),
    QColor(0xFF7BE2),
    QColor(0x6D13FF).lighter(150)
};

constexpr quint32 BlueColorSubChainCount = sizeof(BlueColorSubChain) / sizeof(BlueColorSubChain[0]);

QColor ThemeManager::GetColorFromSubChain(const SubChain subChain, const quint32 index) noexcept
{
    switch (subChain) {
    case SubChain::Red:
        return RedColorSubChain[index % RedColorSubChainCount];
    case SubChain::Green:
        return GreenColorSubChain[index % GreenColorSubChainCount];
    case SubChain::Blue:
        return BlueColorSubChain[index % BlueColorSubChainCount];
    default:
        return QColor();
    }
}
