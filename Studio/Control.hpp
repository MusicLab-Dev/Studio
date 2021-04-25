/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Control
 */

#pragma once

#include <QObject>

#include <Audio/Control.hpp>

#include "Base.hpp"

struct ControlEvent : public Audio::ControlEvent
{
    Q_GADGET

    Q_PROPERTY(ParamID paramID MEMBER paramID)
    Q_PROPERTY(ParamValue value MEMBER value)
public:
    using Audio::ControlEvent::ControlEvent;
    using Audio::ControlEvent::operator=;
};
Q_DECLARE_METATYPE(ControlEvent)