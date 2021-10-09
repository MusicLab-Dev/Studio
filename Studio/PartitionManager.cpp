/**
 * @ Author: Cédric Lucchese
 * @ Description: PartitionManager
 */

#include "PartitionManager.hpp"

#include <QFile>

QString PartitionManager::read(void) const
{
    QFile file(_path);
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    if (!file.exists())
        throw std::logic_error("ProjectManager::read: partition file not found '" + _path.toStdString() + "'");
    auto str = file.readAll();
    file.close();
    return str;
}

void PartitionManager::write(const QString &data) const
{
    QFile file(_path);
    file.open(QIODevice::WriteOnly | QFile::Truncate);
    if (!file.exists())
        throw std::logic_error("ProjectManager::write: partition file not found '" + _path.toStdString() + "'");
    file.write(data.toUtf8());
    file.close();
}
