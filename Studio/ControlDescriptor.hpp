/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Control descriptor
 */

#pragma once

#include <QObject>

#include "PluginModel.hpp"

struct ControlDescriptor
{
private:
    Q_GADGET

    Q_PROPERTY(ParamID controlParamID MEMBER controlParamID)
    Q_PROPERTY(PluginModel::ParamType controlType MEMBER controlType)
    Q_PROPERTY(ParamValue controlMinValue MEMBER controlMinValue)
    Q_PROPERTY(ParamValue controlMaxValue MEMBER controlMaxValue)
    Q_PROPERTY(ParamValue controlStepValue MEMBER controlStepValue)
    Q_PROPERTY(ParamValue controlDefaultValue MEMBER controlDefaultValue)
    Q_PROPERTY(QString controlTitle MEMBER controlTitle)
    Q_PROPERTY(QString controlDescription MEMBER controlDescription)
    Q_PROPERTY(QString controlShortName MEMBER controlShortName)
    Q_PROPERTY(QString controlUnitName MEMBER controlUnitName)
    Q_PROPERTY(QVector<QString> controlRangeNames MEMBER controlRangeNames)

public:
    ParamID controlParamID;
    PluginModel::ParamType controlType;
    ParamValue controlMinValue;
    ParamValue controlMaxValue;
    ParamValue controlStepValue;
    ParamValue controlDefaultValue;
    QString controlTitle;
    QString controlDescription;
    QString controlShortName;
    QString controlUnitName;
    QVector<QString> controlRangeNames;
};
Q_DECLARE_METATYPE(ControlDescriptor)
