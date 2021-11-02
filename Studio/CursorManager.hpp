/**
 * @ Author: Cédric Lucchese
 * @ Description: Cursor Manager
 */

#pragma once

#include <QObject>

class CursorManager : public QObject
{
    Q_OBJECT

public:
    enum class Type {
        Normal,
        Clickable,
        Pressable,
        Press,
        Erase,
        Move,
        ResizeHorizontal,
        ResizeVertical
    };
    Q_ENUM(Type);

    /** @brief Constructor */
    explicit CursorManager(QObject *parent = nullptr) : QObject(parent) {}

    /** @brief Default virtual destructor */
    ~CursorManager(void) override = default;

public slots:
    /** @brief set the cursor image */
    void set(const Type &type) const noexcept;
};