cmake_minimum_required(VERSION 3.10)


# Minimum C++17 for deps
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Enable dependency caching
if(ENV STREQUAL "local")
    set(CMAKE_CXX_COMPILER_LAUNCHER ccache)
endif()

# Coinpay API Project
project(CoinpayAPI)

# Fetch Crow
include(FetchContent)

FetchContent_Declare(
  crow
  GIT_REPOSITORY https://github.com/CrowCpp/crow.git
  GIT_TAG v1.0+3
)

FetchContent_MakeAvailable(crow)

# Fetch Catch2
include(FetchContent)
FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG v3.5.2
)
FetchContent_MakeAvailable(Catch2)

# Fetch Zstd
include(FetchContent)

set(ZSTD_BUILD_STATIC ON CACHE BOOL "" FORCE)
set(ZSTD_BUILD_SHARED OFF CACHE BOOL "" FORCE)
set(ZSTD_BUILD_PROGRAMS OFF CACHE BOOL "" FORCE)
set(ZSTD_BUILD_TESTS OFF CACHE BOOL "" FORCE)

FetchContent_Declare(
    zstd
    GIT_REPOSITORY https://github.com/facebook/zstd.git
    GIT_TAG v1.5.5
)

# Fetch and make available
FetchContent_MakeAvailable(zstd)

add_subdirectory(${zstd_SOURCE_DIR}/build/cmake ${zstd_BINARY_DIR}/zstd-build)

if(NOT TARGET zstd::libzstd)
    add_library(zstd::libzstd ALIAS libzstd_static)
endif()

# Fetch httplib
include(FetchContent)
FetchContent_Declare(
    httplib
    GIT_REPOSITORY https://github.com/yhirose/cpp-httplib.git
    GIT_TAG        master
)
FetchContent_MakeAvailable(httplib)


# API library
file(GLOB_RECURSE SOURCES LIST_DIRECTORIES false src/api/*)

add_library(api-lib STATIC
    ${SOURCES}
)

target_include_directories(api-lib PUBLIC include)
target_include_directories(api-lib PRIVATE ${crow_SOURCE_DIR}/include)

# Add test executable
file(GLOB_RECURSE TEST_SOURCES CONFIGURE_DEPENDS "test/*.cpp")
add_executable(app-tests ${TEST_SOURCES} ${SOURCES})

# Link test targets
target_link_libraries(
    app-tests PRIVATE
    api-lib
    Catch2::Catch2WithMain
    httplib
)
target_include_directories(app-tests PRIVATE ${crow_SOURCE_DIR}/include)

# Link main targets
add_executable(app src/main.cpp)
target_link_libraries(app PRIVATE api-lib)
target_include_directories(app PRIVATE ${crow_SOURCE_DIR}/include)

# List created targets
get_directory_property(dir_targets DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} BUILDSYSTEM_TARGETS)
message(STATUS "=== Created targets ===")
foreach(tgt IN LISTS dir_targets)
    message(STATUS "Target: ${tgt}")
endforeach()

# Enable automatic test discovery
include(Catch)
include(CTest)
catch_discover_tests(app-tests)

# Run tests only once after compilation
add_custom_command(TARGET app-tests POST_BUILD
    COMMAND ctest --output-on-failure
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
