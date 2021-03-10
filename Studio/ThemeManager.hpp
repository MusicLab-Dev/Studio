/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: The theme manager
 */

/*
COLORS:
backgroundColor: "#4A8693"
foregroundColor: "#001E36"
contentColor: "#FFFFF"
disabledColor: "#C4C4C4"
accentColor: "#31A8FF"

sequencerHashKeyColor: "#7B7B7B"
sequencerKeyColor: "#E7E7E7"

IMAGES:
nomralMod: "qrc:/Assets/NormalMod.png",
selectorMod: "qrc:/Assets/SelectorMod.png",
cutMod: "qrc:/Assets/CutMod.png",
editMod: "qrc:/Assets/EditMod.png",
velocityMod: "qrc:/Assets/VelocityMod.png",
tunningMod: "qrc:/Assets/TunningMod.png",
afterTouchMod: "qrc:/Assets/AfterTouchMod.png",

TEXTS:
titleSequencer: "Sequencer"
subTitleSequencer: "Creating sequence with"
*/

#include <QObject>
#include <QColor>

class ThemeManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Theme theme READ theme WRITE setTheme NOTIFY themeChanged)
    Q_PROPERTY(QColor backgroundColor READ backgroundColor NOTIFY backgroundColorChanged)
    Q_PROPERTY(QColor foregroundColor READ foregroundColor NOTIFY foregroundColorChanged)
    Q_PROPERTY(QColor contentColor READ contentColor NOTIFY contentColorChanged)
    Q_PROPERTY(QColor disabledColor READ disabledColor NOTIFY disabledColorChanged)
    Q_PROPERTY(QColor accentColor READ accentColor NOTIFY accentColorChanged)

public:
    /** @brief Preconfigured themes */
    enum class Theme {
        Classic,
        Dark
    };
    Q_ENUMS(Theme)

    /** @brief Construct a theme manager */
    ThemeManager(QObject *parent = nullptr)
        : QObject(parent) { updateThemeColors(); }

    /** @brief Construct a theme manager */
    virtual ~ThemeManager(void) = default;

    /** @brief Get / Set current theme */
    [[nodiscard]] Theme theme(void) const noexcept { return _theme; }
    bool setTheme(const Theme theme);


    /** @brief Color getters */
    [[nodiscard]] QColor backgroundColor(void) const noexcept { return _backgroundColor; }
    [[nodiscard]] QColor foregroundColor(void) const noexcept { return _foregroundColor; }
    [[nodiscard]] QColor contentColor(void) const noexcept { return _contentColor; }
    [[nodiscard]] QColor disabledColor(void) const noexcept { return _disabledColor; }
    [[nodiscard]] QColor accentColor(void) const noexcept { return _accentColor; }

signals:
    /** @brief Notify that theme has changed */
    void themeChanged(void);

    /** @brief Notify that a color changed */
    void backgroundColorChanged(void);
    void foregroundColorChanged(void);
    void contentColorChanged(void);
    void disabledColorChanged(void);
    void accentColorChanged(void);

private:
    Theme _theme { Theme::Classic };
    QColor _backgroundColor {};
    QColor _foregroundColor {};
    QColor _contentColor {};
    QColor _disabledColor {};
    QColor _accentColor {};

    /** @brief Update colors */
    void updateThemeColors(void);
};