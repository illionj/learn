#pragma once

#include <cstddef>
#include <random>
#include <vector>

using dtype = float;
constexpr int SEED = 12345;

std::vector<dtype> makeRandArr(size_t cols, size_t rows = 1);

bool compareFloatArrays(const float* expected, const float* actual, size_t cols, size_t rows = 1,
                        float rtol = 1e-3F, float atol = 1e-3F);
