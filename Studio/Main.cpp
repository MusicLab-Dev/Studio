/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio entry point
 */

#include <iostream>

#include <Studio/Studio.hpp>

int main(int argc, char *argv[])
{
    try {
        Studio studio(argc, argv);

        return studio.run();
    } catch (const std::exception &e) {
        std::cerr << "\nAn error occured:\n\t" << e.what() << std::endl;
    }
}
