add_executable(miniTensor
    miniTensor.cpp
)

target_compile_features(miniTensor PRIVATE cxx_std_20)

target_compile_options(miniTensor PRIVATE
    -Wall
    -Wextra
    -Wpedantic
)
