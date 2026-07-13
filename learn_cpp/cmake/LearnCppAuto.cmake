function(learn_cpp_make_target_name out_var dir)
    get_filename_component(_name "${dir}" NAME)

    if(_name STREQUAL "")
        message(FATAL_ERROR "Cannot derive a target name from directory: ${dir}")
    endif()

    if(NOT _name MATCHES "^[A-Za-z0-9_.+-]+$")
        message(FATAL_ERROR "Directory name is not a valid CMake target name: ${dir}")
    endif()

    set(${out_var} "${_name}" PARENT_SCOPE)
endfunction()

function(learn_cpp_add_auto_executable)
    set(_one_value_args DIR TARGET OUTPUT_DIR)
    cmake_parse_arguments(AUTO "" "${_one_value_args}" "" ${ARGN})

    if(AUTO_DIR)
        set(_dir "${AUTO_DIR}")
    else()
        set(_dir "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    if(NOT IS_DIRECTORY "${_dir}")
        message(FATAL_ERROR "Demo directory does not exist: ${_dir}")
    endif()

    if(AUTO_TARGET)
        set(_target "${AUTO_TARGET}")
    else()
        learn_cpp_make_target_name(_target "${_dir}")
    endif()

    file(GLOB _sources CONFIGURE_DEPENDS
        "${_dir}/*.cpp"
        "${_dir}/*.cxx"
        "${_dir}/*.cc"
    )

    if(NOT _sources)
        message(FATAL_ERROR "No C++ source files found in: ${_dir}")
    endif()

    file(GLOB _headers CONFIGURE_DEPENDS
        "${_dir}/*.h"
        "${_dir}/*.hpp"
        "${_dir}/*.hh"
        "${_dir}/*.hxx"
    )

    if(TARGET "${_target}")
        message(FATAL_ERROR "Target already exists: ${_target}")
    endif()

    add_executable("${_target}" ${_sources} ${_headers})
    target_compile_features("${_target}" PRIVATE cxx_std_20)
    target_compile_options("${_target}" PRIVATE
        -Wall
        -Wextra
        -Wpedantic
        $<$<CXX_COMPILER_ID:Clang>:-Weverything>
    )
    target_include_directories("${_target}" PRIVATE "${_dir}")

    if(TARGET fmt::fmt)
        target_link_libraries("${_target}" PRIVATE fmt::fmt)
    endif()

    if(AUTO_OUTPUT_DIR)
        set(_output_dir "${AUTO_OUTPUT_DIR}")
    elseif(DEFINED LEARN_CPP_AUTO_OUTPUT_DIR)
        set(_output_dir "${LEARN_CPP_AUTO_OUTPUT_DIR}")
    else()
        set(_output_dir "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
    endif()

    if(_output_dir)
        set_target_properties("${_target}" PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY "${_output_dir}"
            RUNTIME_OUTPUT_DIRECTORY_DEBUG "${_output_dir}"
            RUNTIME_OUTPUT_DIRECTORY_RELEASE "${_output_dir}"
            RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${_output_dir}"
            RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${_output_dir}"
        )
    endif()
endfunction()

function(learn_cpp_add_demo_tree root_dir)
    set(_one_value_args OUTPUT_DIR)
    cmake_parse_arguments(TREE "" "${_one_value_args}" "" ${ARGN})

    if(IS_ABSOLUTE "${root_dir}")
        set(_root "${root_dir}")
    else()
        set(_root "${CMAKE_CURRENT_SOURCE_DIR}/${root_dir}")
    endif()

    if(NOT IS_DIRECTORY "${_root}")
        message(FATAL_ERROR "Demo root does not exist: ${_root}")
    endif()

    if(TREE_OUTPUT_DIR)
        set(LEARN_CPP_AUTO_OUTPUT_DIR "${TREE_OUTPUT_DIR}")
    else()
        set(LEARN_CPP_AUTO_OUTPUT_DIR "${_root}/bin")
    endif()

    file(GLOB _children LIST_DIRECTORIES true CONFIGURE_DEPENDS "${_root}/*")
    foreach(_child IN LISTS _children)
        if(NOT IS_DIRECTORY "${_child}")
            continue()
        endif()

        if(EXISTS "${_child}/CMakeLists.txt")
            add_subdirectory("${_child}")
            continue()
        endif()

        file(GLOB _child_sources CONFIGURE_DEPENDS
            "${_child}/*.cpp"
            "${_child}/*.cxx"
            "${_child}/*.cc"
        )

        if(_child_sources)
            learn_cpp_add_auto_executable(DIR "${_child}" OUTPUT_DIR "${LEARN_CPP_AUTO_OUTPUT_DIR}")
        endif()
    endforeach()
endfunction()
