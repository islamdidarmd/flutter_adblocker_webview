# Sets the minimum version of CMake required to build your native library.
# This ensures that a certain set of CMake features is available to
# your build.

cmake_minimum_required(VERSION 3.10)

add_library( # Specifies the name of the library.
             hello

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
        ../shared/hello.c)

set_target_properties(hello PROPERTIES
    PUBLIC_HEADER ../shared/hello.h
    OUTPUT_NAME "hello"
)
target_compile_definitions(hello PUBLIC DART_SHARED_LIB)
