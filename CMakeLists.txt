cmake_minimum_required(VERSION 3.13 FATAL_ERROR)

get_filename_component(StudioRoot ${CMAKE_CURRENT_LIST_FILE} PATH)

include(${StudioRoot}/CompileOptions/ToolchainOptions.cmake)

project(Studio)

# if(MSVC)
#     message("/!\\ Compiling for static MSVC /!\\")
#     add_compile_options(
#         $<$<CONFIG:>:/MT> #---------|
#         $<$<CONFIG:Debug>:/MTd> #---|-- Statically link the runtime libraries
#         $<$<CONFIG:Release>:/MT> #--|
#     )
# endif()

include(${StudioRoot}/CompileOptions/CompileOptions.cmake)

add_submodule_directory(${StudioRoot}/Audio)
include(${StudioRoot}/Protocol/Protocol/Protocol.cmake)

include(${StudioRoot}/Studio/Studio.cmake)

if(TESTS)
    enable_testing()
    include(${StudioRoot}/Tests/StudioTests.cmake)
endif()

if(BENCHMARKS)
    include(${StudioRoot}/Benchmarks/StudioBenchmarks.cmake)
endif()
