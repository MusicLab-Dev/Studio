/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Project Serializer
 */

template<typename Iterator>
inline QJsonArray ProjectSerializer::SerializeArray(Iterator begin, const Iterator end) noexcept
{
    QJsonArray array;

    while (begin != end) {
        array << *begin;
        ++begin;
    }
    return array;
}

template<typename Iterator, typename Functor>
inline QJsonArray ProjectSerializer::SerializeArray(Iterator begin, const Iterator end, Functor &&functor) noexcept
{
    QJsonArray array;

    while (begin != end) {
        array << functor(*begin);
        ++begin;
    }
    return array;
}

template<typename Range, typename Functor>
inline QJsonArray ProjectSerializer::SerializeArray(const Range range, Functor &&functor) noexcept
{
    QJsonArray array;

    for (Range i = 0; i < range; ++i) {
        array << functor(i);
    }
    return array;
}