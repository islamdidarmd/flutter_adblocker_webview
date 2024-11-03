# Do not change this cmake_minimum_required version.
# This version is recommended for flutter.

cmake_minimum_required(VERSION 3.10)

file(GLOB ADBLOCK_SOURCES 
     "../native/third-party/ad-block/*.cc"
     "../native/third-party/ad-block/*.cpp"
     "../native/third-party/bloom-filter-cpp/*.cpp"
     "../native/third-party/bloom-filter-cpp/*.cc"
     "../native/third-party/hashset-cpp/*.cpp"
     "../native/third-party/hashset-cpp/*.cc"
)

add_library(adblocker_core
             SHARED
             ../native/adblocker_core.cpp
             ${ADBLOCK_SOURCES}
             )

target_include_directories(adblocker_core PRIVATE
    ../native/third-party/ad-block
)

set_target_properties(adblocker_core PROPERTIES
    PUBLIC_HEADER ../native/adblocker_core.h
    OUTPUT_NAME "adblocker_core"
)
target_compile_definitions(adblocker_core PUBLIC DART_SHARED_LIB)
