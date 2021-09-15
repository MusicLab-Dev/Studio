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
    /* background: */ "#525252",
    /* foreground: */ "#242424",
    /* content: */ "#FFFFFF",
    /* accent: */ "#31A8FF",
    /* timeline: */ "#00ECBA",
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
        _backgroundColor = pack.background;
        _foregroundColor = pack.foreground;
        _contentColor = pack.content;
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
    emit backgroundColorChanged();
    emit foregroundColorChanged();
    emit contentColorChanged();
    emit accentColorChanged();
    emit timelineColorChanged();
    emit disabledColorChanged();
}

static const QColor ColorChain[] = {
    QColor(0x31A8FF),
    QColor(0x00D1FF),
    QColor(0x00ECBA),
    QColor(0x53C989),
    QColor(0x00A261),
    QColor(0x40B436),
    QColor(0xEDB012),
    QColor(0xFFB377),
    QColor(0xFF9B85),
    QColor(0xFF6F6F),
    QColor(0xDF83CE),
    QColor(0xAC90EC),
};

constexpr quint32 ColorChainCount = sizeof(ColorChain) / sizeof(ColorChain[0]);

QColor ThemeManager::GetColorFromChain(const quint32 index) noexcept
{
    return ColorChain[index % ColorChainCount];
}

static const QColor RedColorSubChain[] = {
    QColor(0xF95D51),
    QColor(0xFFA965),
    QColor(0xFFD159),
    QColor(0xF9F871),
    QColor(0xFF978F),
    QColor(0xF382BB),
};

constexpr quint32 RedColorSubChainCount = sizeof(RedColorSubChain) / sizeof(RedColorSubChain[0]);

static const QColor GreenColorSubChain[] = {
    QColor(0x40B436),
    QColor(0x46FF42),
    QColor(0x42FF8E),
    QColor(0x31E9A7),
    QColor(0x53C989),
    QColor(0x00A261),
};

constexpr quint32 GreenColorSubChainCount = sizeof(GreenColorSubChain) / sizeof(GreenColorSubChain[0]);

static const QColor BlueColorSubChain[] = {
    QColor(0x00C5FF),
    QColor(0x00DCE7),
    QColor(0x00A4AF),
    QColor(0x008FC6),
    QColor(0x8E98F7),
    QColor(0xAC90EC),
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
