cmake_minimum_required(VERSION 3.16)

project(learn_cpp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_compile_options($<$<CONFIG:Debug>:-gdwarf-4>)

set(FMT_DOC OFF CACHE BOOL "" FORCE)
set(FMT_TEST OFF CACHE BOOL "" FORCE)
set(FMT_INSTALL OFF CACHE BOOL "" FORCE)
add_subdirectory(third_party/fmt)
get_target_property(_fmt_include_dirs fmt INTERFACE_INCLUDE_DIRECTORIES)
if(_fmt_include_dirs)
    set_target_properties(fmt PROPERTIES
        INTERFACE_SYSTEM_INCLUDE_DIRECTORIES "${_fmt_include_dirs}"
    )
endif()

include(cmake/LearnCppAuto.cmake)

learn_cpp_add_demo_tree(leetcode)
learn_cpp_add_demo_tree(demos)
