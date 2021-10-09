/**
 * @ Author: Cédric Lucchese
 * @ Description: Cursor Manager
 */

#include <QCursor>
#include <QGuiApplication>

#include "CursorManager.hpp"

void CursorManager::set(const CursorManager::Type &type) const noexcept
{

    if (QGuiApplication::overrideCursor() != nullptr) // Release previous override
        QGuiApplication::restoreOverrideCursor();
    switch (type)
    {
//    case CursorManager::Type::Normal:
//        QGuiApplication::setOverrideCursor(QCursor(Qt::ArrowCursor));
//        break;
    case CursorManager::Type::Clickable:
        QGuiApplication::setOverrideCursor(QCursor(Qt::PointingHandCursor));
        break;
    case CursorManager::Type::Pressable:
        QGuiApplication::setOverrideCursor(QCursor(Qt::OpenHandCursor));
        break;
    case CursorManager::Type::Press:
        QGuiApplication::setOverrideCursor(QCursor(Qt::ClosedHandCursor));
        break;
    case CursorManager::Type::Erase:
        QGuiApplication::setOverrideCursor(QCursor(Qt::ForbiddenCursor));
        break;
    case CursorManager::Type::Move:
        QGuiApplication::setOverrideCursor(QCursor(Qt::SizeAllCursor));
        break;
    case CursorManager::Type::ResizeHorizontal:
        QGuiApplication::setOverrideCursor(QCursor(Qt::SizeHorCursor));
        break;
    case CursorManager::Type::ResizeVertical:
        QGuiApplication::setOverrideCursor(QCursor(Qt::SizeVerCursor));
        break;
    default:
        break;
    };
}
