# Sets the minimum version of CMake required to build your native library.
# This ensures that a certain set of CMake features is available to
# your build.

cmake_minimum_required(VERSION 3.10)

add_library( # Specifies the name of the library.
             adblocker_core

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             ../shared/adblocker_core.c)

set_target_properties(adblocker_core PROPERTIES
    PUBLIC_HEADER ../shared/adblocker_core.h
    OUTPUT_NAME "adblocker_core"
)
target_compile_definitions(adblocker_core PUBLIC DART_SHARED_LIB)
