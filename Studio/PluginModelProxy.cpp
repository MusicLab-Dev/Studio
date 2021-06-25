/*
 * @ Author: Matthieu Moinvaziri
 * @ Description: PluginModel Proxy
 */

#include "PluginModelProxy.hpp"

bool PluginModelProxy::filterAcceptsRow(int , const QModelIndex &) const
{
    return true;
}