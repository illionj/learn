#include "cuda_check.h"
#include "utils.h"
#include <nvtx3/nvToolsExt.h>
#include <random>

__host__ void reduction_host(const float* input, float* output, int N)
{
    float temp = 0.0f;
    for (int i = 0; i < N; ++i)
    {
        temp += input[i];
    }
    *output = temp;
}

__global__ void reduce_v0(const float* input, float* output, int n) {}

int main()
{

    const int M = 335;

    const auto input_h = makeRandArr(M);
    float outputHost = 0.0f;
    float output_h = 0.0f;

    float* input_d = nullptr;
    float* output_d = nullptr;
    cudaMalloc((void**) &input_d, M * sizeof(float));
    cudaMalloc((void**) &output_d, 1 * sizeof(float));

    cudaMemcpy(input_d, input_h.data(), M * sizeof(float), cudaMemcpyHostToDevice);
    dim3 threadPerBlock(16);
    dim3 blocksPerGrid((M + threadPerBlock.x - 1) / M);
    reduce_v0<<<blocksPerGrid, threadPerBlock>>>(input_d, output_d, M);
    cudaMemcpy(&output_h, output_d, sizeof(float), cudaMemcpyDeviceToHost);
    reduction_host(input_h.data(), &outputHost, M);

    compareFloatArrays(&output_h, &outputHost, 1, 1);
}