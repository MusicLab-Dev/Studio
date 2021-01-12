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
};


static const ThemePack ClassicThemePack {
    .background = "#4A8693",
    .foreground = "#001E36",
    .content = "#FFFFFF",
    .disabled = "#C4C4C4",
    .accent = "#31A8FF"
};

static const ThemePack DarkThemePack {
    .background = "#4A8693",
    .foreground = "#001E36",
    .content = "#FFFFFF",
    .disabled = "#C4C4C4",
    .accent = "#31A8FF"
};

bool ThemeManager::setTheme(const Theme theme)
{
    if (_theme == theme)
        return false;
    _theme = theme;
    emit themeChanged();
    updateThemeColors();
    return true;
}

void ThemeManager::updateThemeColors(void)
{
    const auto ApplyTheme = [this](const ThemePack &pack) {
        _backgroundColor = pack.background;
        _foregroundColor = pack.foreground;
        _contentColor = pack.content;
        _disabledColor = pack.disabled;
        _accentColor = pack.accent;
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
