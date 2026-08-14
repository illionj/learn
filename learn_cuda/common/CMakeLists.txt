file(GLOB LEARN_CUDA_COMMON_HEADERS CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cuh"
)

file(GLOB LEARN_CUDA_COMMON_SOURCES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cu"
)

add_library(learn_cuda_common STATIC
    ${LEARN_CUDA_COMMON_HEADERS}
    ${LEARN_CUDA_COMMON_SOURCES}
)

target_include_directories(learn_cuda_common
    PUBLIC
        "${CMAKE_CURRENT_SOURCE_DIR}"
)

target_compile_features(learn_cuda_common
    PUBLIC
        cxx_std_20
)

target_link_libraries(learn_cuda_common
    PUBLIC
        fmt::fmt
)

set_target_properties(learn_cuda_common PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON
)
