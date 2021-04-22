/**
 * @ Author: Gonzalez Dorian
 * @ Description: Control Model class
 */

#include <QQmlEngine>
#include <QHash>

#include "Models.hpp"
#include "ControlsModel.hpp"

ControlModel::ControlModel(Audio::Control *control, ControlsModel *parent, const QString &name) noexcept
    : QAbstractListModel(parent), _data(control), _name(name)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
    _automations.reserve(_data->automations().size());
    for (auto &automation : _data->automations())
        _automations.push(&automation, this);
}

QHash<int, QByteArray> ControlModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(ControlModel::Roles::AutomationInstance), "automationInstance"}
    };
}

QVariant ControlModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() >= 0 && index.row() < count(),
        throw std::range_error("ControlModel::get: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    switch (static_cast<ControlModel::Roles>(role)) {
    case ControlModel::Roles::AutomationInstance:
        return QVariant::fromValue(AutomationWrapper { const_cast<AutomationModel *>(get(index.row())) });
    default:
        return QVariant();
    }
}

const AutomationModel *ControlModel::get(const int index) const noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("ControlModel::get: Given index is not in range: " + std::to_string(index) + " out of [0, " + std::to_string(count()) + "["));
    return _automations.at(index).get();
}

void ControlModel::setParamID(const ParamID paramID)
{
    Models::AddProtectedEvent(
        [this, paramID] {
            _data->setParamID(paramID);
        },
        [this, paramID = _data->paramID()] {
            if (paramID != _data->paramID())
                emit paramIDChanged();
        }
    );
}

void ControlModel::setMuted(const bool muted)
{
    Models::AddProtectedEvent(
        [this, muted] {
            _data->setMuted(muted);
        },
        [this, muted = _data->muted()] {
            if (muted != _data->muted())
                emit mutedChanged();
        }
    );
}

void ControlModel::setManualMode(const bool manualMode)
{
    Models::AddProtectedEvent(
        [this, manualMode] {
            _data->setManualMode(manualMode);
        },
        [this, manualMode = _data->manualMode()] {
            if (manualMode != _data->manualMode())
                emit manualModeChanged();
        }
    );
}

void ControlModel::setManualPoint(const GPoint &manualPoint)
{
    Models::AddProtectedEvent(
        [this, manualPoint] {
            _data->setManualPoint(manualPoint);
        },
        [this, manualPoint = _data->manualPoint()] {
            if (manualPoint != _data->manualPoint())
                emit manualPointChanged();
        }
    );
}

void ControlModel::setName(const QString &name)
{
    Models::AddProtectedEvent(
        [this, name] {
            this->setName(name);
        },
        [this, name = this->name()] {
            if (name != this->name())
                emit nameChanged();
        }
    );
}

bool ControlModel::add(void)
{
    // Get a unique name for this automation
    std::string name = [this] {
        std::string name;
        auto size = _automations.size();
        while (true) {
            bool unique = true;
            name = "Curve " + std::to_string(size);
            for (auto &automation : _data->automations()) {
                if (automation.name() == name) {
                    unique = false;
                    break;
                }
            }
            if (unique)
                break;
            ++size;
        }
        return name;
    }();

    return Models::AddProtectedEvent(
        [this, name = Core::FlatString(std::move(name))](void) mutable {
            _data->automations().push().setName(std::move(name));
        },
        [this] {
            const auto automationsData = _automations.data();
            const auto idx = _automations.size();
            beginInsertRows(QModelIndex(), idx, idx);
            _automations.push(&_data->automations().at(idx), this);
            endInsertRows();
            if (_automations.data() != automationsData)
                refreshAutomations();
        }
    );
}

bool ControlModel::remove(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("ControlModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    return Models::AddProtectedEvent(
        [this, idx] {
            _data->automations().erase(_data->automations().begin() + idx);
        },
        [this, idx] {
            beginRemoveRows(QModelIndex(), idx, idx);
            _automations.erase(_automations.begin() + idx);
            endRemoveRows();
            const auto count = _automations.size();
            for (auto i = idx + 1; i < count; ++i)
                _automations.at(i)->updateInternal(&_data->automations().at(i));
        }
    );
}

bool ControlModel::move(const int from, const int to)
{
    if (from == to)
        return false;
    coreAssert(from >= 0 && from < count() && to >= 0 && to < count(),
        throw std::range_error("ControlModel::move: Given index is not in range: [" + std::to_string(from) + ", " + std::to_string(to) + "[ out of [0, " + std::to_string(count()) + "["));
    return Models::AddProtectedEvent(
        [this, from, to] {
            _data->automations().move(from, from, to);
        },
        [this, from, to] {
            beginMoveRows(QModelIndex(), from, from, QModelIndex(), to ? to + 1 : 0);
            _automations.move(from, from, to);
            endMoveRows();
            _automations.at(from)->updateInternal(&_data->automations().at(from));
            _automations.at(to)->updateInternal(&_data->automations().at(to));
        }
    );
}

void ControlModel::updateInternal(Audio::Control *data)
{
    if (_data == data)
        return;
    std::swap(_data, data);
    if (_data->automations().data() != data->automations().data())
        refreshAutomations();
}

void ControlModel::refreshAutomations(void)
{
    Models::RefreshModels(this, _automations, _data->automations(), this);
}