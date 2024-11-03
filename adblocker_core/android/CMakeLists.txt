# Sets the minimum version of CMake required to build your native library.
# This ensures that a certain set of CMake features is available to
# your build.

cmake_minimum_required(VERSION 3.10)

# Gather all source files from related directories
file(GLOB ADBLOCK_SOURCES 
     "../native/third-party/ad-block/*.cc"
     "../native/third-party/ad-block/*.cpp"
     "../native/third-party/bloom-filter-cpp/*.cpp"
     "../native/third-party/bloom-filter-cpp/*.cc"
     "../native/third-party/hashset-cpp/*.cpp"
     "../native/third-party/hashset-cpp/*.cc"
)

add_library( # Specifies the name of the library.
             adblocker_core

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             ../native/adblocker_core.cpp
             # Add the AdBlock library source files
             ${ADBLOCK_SOURCES}
             # Add any other required source files
)

# Add include directories if needed
target_include_directories(adblocker_core PRIVATE
    ../native/third-party/ad-block
)

set_target_properties(adblocker_core PROPERTIES
    PUBLIC_HEADER ../native/adblocker_core.h
    OUTPUT_NAME "adblocker_core"
)
target_compile_definitions(adblocker_core PUBLIC DART_SHARED_LIB)
