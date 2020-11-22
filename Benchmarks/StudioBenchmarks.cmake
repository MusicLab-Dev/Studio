project(StudioBenchmarks)

find_package(benchmark REQUIRED)

get_filename_component(StudioBenchmarksDir ${CMAKE_CURRENT_LIST_FILE} PATH)

set(StudioBenchmarksSources
    ${StudioBenchmarksDir}/Main.cpp
)

add_executable(${PROJECT_NAME} ${StudioBenchmarksSources})

target_link_libraries(${PROJECT_NAME}
PUBLIC
    Studio
    benchmark::benchmark
)
