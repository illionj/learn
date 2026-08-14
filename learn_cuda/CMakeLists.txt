cmake_minimum_required(VERSION 3.16)

project(learn_cuda LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# CMake 3.20 predates NVCC's CUDA C++20 flag mapping. Supply the mapping when
# the installed CMake does not know it, while still using CUDA_STANDARD below.
if(CMAKE_CUDA_COMPILER_ID STREQUAL "NVIDIA"
   AND NOT DEFINED CMAKE_CUDA20_STANDARD_COMPILE_OPTION)
    set(CMAKE_CUDA20_STANDARD_COMPILE_OPTION "-std=c++20")
    set(CMAKE_CUDA20_EXTENSION_COMPILE_OPTION "-std=c++20")
endif()

set(CMAKE_CUDA_STANDARD 20)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_EXTENSIONS OFF)

if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES 120 CACHE STRING "CUDA architectures")
endif()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

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

add_subdirectory(common)

include(cmake/LearnCudaAuto.cmake)

learn_cuda_add_demo_tree(pmpp)
learn_cuda_add_demo_tree(leetGPU)
