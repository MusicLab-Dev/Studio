/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Colored sprite manager
 */

template<typename Functor>
inline void ColoredSpriteManager::query(const QString &path, Functor &&functor)
{
    auto tableIt = _table.find(path);

    if (tableIt != _table.end()) {
        functor(path, *tableIt);
        return;
    }

    auto it = _loadTable.find(path);

    if (it != _loadTable.end()) {
        it->push(LoadFunc { std::forward<Functor>(functor) });
    } else {
        _loadTable.insert(path, LoadCache {
            LoadFunc { std::forward<Functor>(functor) }
        });
        if (!_thread.queue().push(path)) {
            // Push failed in async queue, we must load synchronously
            const auto cache = ImageLoaderThread::Load(path);
            functor(path, cache);
            _table.insert(path, cache);
        }
        if (!_thread.isRunning())
            _thread.start();
    }
}
