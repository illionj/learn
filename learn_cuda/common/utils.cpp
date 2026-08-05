#include "utils.h"

#include <cmath>
#include <fmt/base.h>
#include <fmt/core.h>
#include <random>

std::vector<dtype> makeRandArr(size_t cols, size_t rows)
{
    // std::random_device rd;
    // std::mt19937 gen(rd());
    std::mt19937 gen(SEED);
    std::normal_distribution<float> dis(0.0f, 1.0f);

    std::vector<float> arr;
    arr.resize(rows * cols, 0.0f);
    for (size_t row = 0; row < rows; ++row)
    {
        for (size_t col = 0; col < cols; ++col)
        {
            size_t idx = row * cols + col;
            arr[idx] = dis(gen);
        }
    }
    return arr;
}

bool compareFloatArrays(const float* expected, const float* actual, size_t rows, size_t cols,
                        float rtol, float atol)
{
    for (size_t row = 0; row < rows; ++row)
    {
        for (size_t col = 0; col < cols; ++col)
        {
            const size_t index = row * cols + col;
            const float expected_value = expected[index];
            const float actual_value = actual[index];
            const float diff = std::abs(expected_value - actual_value);
            const float tolerance = atol + rtol * std::abs(expected_value);

            if (!std::isfinite(expected_value) || !std::isfinite(actual_value) || diff > tolerance)
            {
                fmt::print(stderr,
                           "Float arrays differ at row={}, col={}: expected={}, actual={}, "
                           "diff={}, tolerance={}\n",
                           row, col, expected_value, actual_value, diff, tolerance);
                return false;
            }
        }
    }
    fmt::println("float arrays equal");
    return true;
}
