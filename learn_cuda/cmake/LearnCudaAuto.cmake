function(learn_cuda_make_target_name out_var root_dir source_file)
    file(RELATIVE_PATH _relative_source "${CMAKE_SOURCE_DIR}" "${source_file}")
    get_filename_component(_source_dir "${_relative_source}" DIRECTORY)
    get_filename_component(_source_name "${_relative_source}" NAME_WE)

    if(_source_dir STREQUAL "")
        set(_target "${_source_name}")
    else()
        string(REPLACE "/" "_" _target_dir "${_source_dir}")
        set(_target "${_target_dir}_${_source_name}")
    endif()

    string(REGEX REPLACE "[^A-Za-z0-9_.+-]" "_" _target "${_target}")

    if(_target STREQUAL "")
        message(FATAL_ERROR "Cannot derive a target name from source file: ${source_file}")
    endif()

    set(${out_var} "${_target}" PARENT_SCOPE)
endfunction()

function(learn_cuda_source_has_main out_var source_file)
    file(READ "${source_file}" _source_content)

    if(_source_content MATCHES "(^|[\n\r])[ \t]*(int|auto)[ \t\n\r]+main[ \t\n\r]*\\(")
        set(${out_var} TRUE PARENT_SCOPE)
    else()
        set(${out_var} FALSE PARENT_SCOPE)
    endif()
endfunction()

function(learn_cuda_make_output_name out_var root_dir source_file)
    file(RELATIVE_PATH _relative_source "${root_dir}" "${source_file}")
    get_filename_component(_source_dir "${_relative_source}" DIRECTORY)
    get_filename_component(_source_name "${_relative_source}" NAME_WE)

    if(_source_dir STREQUAL "")
        set(_output_name "${_source_name}")
    else()
        string(REPLACE "/" "_" _output_dir_name "${_source_dir}")
        set(_output_name "${_output_dir_name}_${_source_name}")
    endif()

    string(REGEX REPLACE "[^A-Za-z0-9_.+-]" "_" _output_name "${_output_name}")

    if(_output_name STREQUAL "")
        message(FATAL_ERROR "Cannot derive an output name from source file: ${source_file}")
    endif()

    set(${out_var} "${_output_name}" PARENT_SCOPE)
endfunction()

function(learn_cuda_add_executable)
    set(_one_value_args ROOT_DIR SOURCE OUTPUT_DIR TARGET)
    cmake_parse_arguments(CUDA_DEMO "" "${_one_value_args}" "" ${ARGN})

    if(NOT CUDA_DEMO_ROOT_DIR)
        message(FATAL_ERROR "learn_cuda_add_executable requires ROOT_DIR")
    endif()

    if(NOT CUDA_DEMO_SOURCE)
        message(FATAL_ERROR "learn_cuda_add_executable requires SOURCE")
    endif()

    if(CUDA_DEMO_TARGET)
        set(_target "${CUDA_DEMO_TARGET}")
    else()
        learn_cuda_make_target_name(_target "${CUDA_DEMO_ROOT_DIR}" "${CUDA_DEMO_SOURCE}")
    endif()

    if(TARGET "${_target}")
        message(FATAL_ERROR "Target already exists: ${_target}")
    endif()

    get_filename_component(_source_dir "${CUDA_DEMO_SOURCE}" DIRECTORY)
    learn_cuda_make_output_name(_output_name "${CUDA_DEMO_ROOT_DIR}" "${CUDA_DEMO_SOURCE}")

    add_executable("${_target}" "${CUDA_DEMO_SOURCE}")
    target_compile_features("${_target}" PRIVATE cxx_std_20 cuda_std_17)
    target_include_directories("${_target}" PRIVATE "${_source_dir}")
    target_compile_options("${_target}" PRIVATE
        $<$<COMPILE_LANGUAGE:CXX>:-Wall>
        $<$<COMPILE_LANGUAGE:CXX>:-Wextra>
        $<$<COMPILE_LANGUAGE:CXX>:-Wpedantic>
        $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CXX_COMPILER_ID:Clang>>:-Weverything>
    )

    if(TARGET fmt::fmt)
        target_link_libraries("${_target}" PRIVATE fmt::fmt)
    endif()

    if(CUDA_DEMO_OUTPUT_DIR)
        set(_output_dir "${CUDA_DEMO_OUTPUT_DIR}")
    elseif(DEFINED LEARN_CUDA_AUTO_OUTPUT_DIR)
        set(_output_dir "${LEARN_CUDA_AUTO_OUTPUT_DIR}")
    else()
        set(_output_dir "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
    endif()

    if(_output_dir)
        set_target_properties("${_target}" PROPERTIES
            OUTPUT_NAME "${_output_name}"
            RUNTIME_OUTPUT_DIRECTORY "${_output_dir}"
            RUNTIME_OUTPUT_DIRECTORY_DEBUG "${_output_dir}"
            RUNTIME_OUTPUT_DIRECTORY_RELEASE "${_output_dir}"
            RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${_output_dir}"
            RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${_output_dir}"
        )
    else()
        set_target_properties("${_target}" PROPERTIES
            OUTPUT_NAME "${_output_name}"
        )
    endif()
endfunction()

function(learn_cuda_add_demo_tree root_dir)
    set(_one_value_args OUTPUT_DIR)
    cmake_parse_arguments(TREE "" "${_one_value_args}" "" ${ARGN})

    if(IS_ABSOLUTE "${root_dir}")
        set(_root "${root_dir}")
    else()
        set(_root "${CMAKE_CURRENT_SOURCE_DIR}/${root_dir}")
    endif()

    if(NOT IS_DIRECTORY "${_root}")
        message(FATAL_ERROR "CUDA demo root does not exist: ${_root}")
    endif()

    if(TREE_OUTPUT_DIR)
        set(LEARN_CUDA_AUTO_OUTPUT_DIR "${TREE_OUTPUT_DIR}")
    else()
        set(LEARN_CUDA_AUTO_OUTPUT_DIR "${_root}/bin")
    endif()

    file(GLOB_RECURSE _cuda_sources CONFIGURE_DEPENDS "${_root}/*.cu")
    list(SORT _cuda_sources)

    foreach(_source IN LISTS _cuda_sources)
        learn_cuda_source_has_main(_has_main "${_source}")
        if(_has_main)
            learn_cuda_add_executable(
                ROOT_DIR "${_root}"
                SOURCE "${_source}"
                OUTPUT_DIR "${LEARN_CUDA_AUTO_OUTPUT_DIR}"
            )
        endif()
    endforeach()
endfunction()
