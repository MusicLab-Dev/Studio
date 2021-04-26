/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: ThemeManager
 */

#include "ThemeManager.hpp"

struct ThemePack
{
    QColor background {};
    QColor foreground {};
    QColor content {};
    QColor disabled {};
    QColor accent {};
    QColor line {};
};

static const ThemePack ClassicThemePack {
    /* background: */ "#3E4756",
    /* foreground: */ "#001E36",
    /* content: */ "#FFFFFF",
    /* disabled: */ "#C4C4C4",
    /* accent: */ "#31A8FF",
    /* line: */ "#00000"
};

static const ThemePack DarkThemePack {
    /* background: */ "#525252",
    /* foreground: */ "#242424",
    /* content: */ "#FFFFFF",
    /* disabled: */ "#C4C4C4",
    /* accent: */ "#31A8FF",
    /* line: */ "#FFFFFF"
};

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
        _disabledColor = pack.disabled;
        _accentColor = pack.accent;
        _lineColor = pack.line;
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
    emit disabledColorChanged();
    emit accentColorChanged();
}

static const QColor ColorChain[] = {
    QColor(0x31A8FF),
    QColor(0x00C5FF),
    QColor(0x00DCE7),
    QColor(0x00ECBA),
    QColor(0x9EF78C),
    QColor(0xFFD569),
    QColor(0xFFB377),
    QColor(0xFF978F),
    QColor(0xFF85A8),
    QColor(0xF382BB),
    QColor(0xDF83CE),
    QColor(0xC487DE),
    QColor(0xAC90EC),
    QColor(0x8E98F7),
    QColor(0x69A1FD)
};

constexpr quint32 ColorChainCount = sizeof(ColorChain) / sizeof(ColorChain[0]);

QColor ThemeManager::GetColorFromChain(const quint32 index) noexcept
{
    return ColorChain[index % ColorChainCount];
}
