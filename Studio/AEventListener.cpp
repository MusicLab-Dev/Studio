/**
 * @ Author: Cédric Lucchese
 * @ Description: Abstract event listener cpp
 */

#include "EventDispatcher.hpp"
#include "AEventListener.hpp"

AEventListener::AEventListener(EventDispatcher *dispatcher)
    : QAbstractListModel(dispatcher), _dispatcher(dispatcher)
{
}
