cmake_minimum_required(VERSION 3.13 FATAL_ERROR)
project(Studio)

get_filename_component(StudioRoot ${CMAKE_CURRENT_LIST_FILE} PATH)

include(${StudioRoot}/CompileOptions/CompileOptions.cmake)

add_submodule_directory(${StudioRoot}/Audio)

include(${StudioRoot}/Studio/Studio.cmake)

if(TESTS)
    enable_testing()
    include(${StudioRoot}/Tests/StudioTests.cmake)
endif()

if(BENCHMARKS)
    include(${StudioRoot}/Benchmarks/StudioBenchmarks.cmake)
endif()