
#include <cmath>
#include <cuda_runtime.h>
#include <fmt/core.h>
#include <iostream>

__global__ void vecAddKernel(float* A, float* B, float* C, int n)
{
    int i = threadIdx.x + blockDim.x * blockIdx.x;
    if (i < n)
    {
        C[i] = A[i] + B[i];
    }
}

void vecAdd(float* A_h, float* B_h, float* C_h, int n)
{
    float* A_d = nullptr;
    float* B_d = nullptr;
    float* C_d = nullptr;
    int size = n * sizeof(float);
    cudaMalloc(&A_d, size);
    cudaMalloc(&B_d, size);
    cudaMalloc(&C_d, size);
    cudaMemcpy(A_d, A_h, size, cudaMemcpyHostToDevice);
    cudaMemcpy(B_d, B_h, size, cudaMemcpyHostToDevice);
    cudaMemcpy(C_d, C_h, size, cudaMemcpyHostToDevice);

    vecAddKernel<<<ceil(n / 256.0), 256>>>(A_d, B_d, C_d, n);

    cudaMemcpy(C_h, C_d, size, cudaMemcpyDeviceToHost);

    cudaFree(A_d);
    cudaFree(B_d);
    cudaFree(C_d);
}

int main()
{
    constexpr int N = 5;
    float A_h[N] = {1, 2, 3, 4, 5};
    float B_h[N] = {2, 3, 4, 5, 6};
    float C_h[N] = {0};
    vecAdd(A_h, B_h, C_h, N);
    for (int i = 0; i < N; i++)
    {
        std::cout << "C_h[" << i << "]=" << C_h[i] << '\n';
    }
    fmt::print("value = {}\n", 1);
}