#include <cuda_runtime.h>
#include <fmt/core.h>
#include <fmt/ranges.h>

static inline void cudaCheck(cudaError_t err, const char* expr, const char* file, int line)
{
    if (err != cudaSuccess)
    {
        fmt::print(stderr, "CUDA error: {}\nexpr: {}\nfile: {}\nline: {}\n",
                   cudaGetErrorString(err), expr, file, line);
        std::exit(EXIT_FAILURE);
    }
}

#define CUDA_CHECK(call) cudaCheck(call, #call, __FILE__, __LINE__)
