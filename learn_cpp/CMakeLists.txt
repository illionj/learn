cmake_minimum_required(VERSION 3.16)

project(learn_cpp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_compile_options($<$<CONFIG:Debug>:-gdwarf-4>)

add_subdirectory(demos/1.miniTensor)
