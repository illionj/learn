#include "cuda_check.h"
#include "utils.h"

__global__ void vector_add(const float* A, const float* B, float* C, int N)
{
    int idx = blockDim.x * blockIdx.x + threadIdx.x;
    if (idx >= N)
        return;
    C[idx] = A[idx] + B[idx];
}

extern "C" void solve(const float* A, const float* B, float* C, int N)
{
    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;
    float* A_d = nullptr;
    float* B_d = nullptr;
    float* C_d = nullptr;
    const auto arr_size = sizeof(float) * N;
    cudaMalloc((void**) &A_d, arr_size);
    cudaMalloc((void**) &B_d, arr_size);
    cudaMalloc((void**) &C_d, arr_size);

    cudaMemcpy(A_d, A, arr_size, cudaMemcpyHostToDevice);
    cudaMemcpy(B_d, B, arr_size, cudaMemcpyHostToDevice);

    vector_add<<<blocksPerGrid, threadsPerBlock>>>(A_d, B_d, C_d, N);
    cudaMemcpy(C, C_d, arr_size, cudaMemcpyDeviceToHost);
}

void vector_add_host(const float* A, const float* B, float* C, int N)
{
    for (int i = 0; i < N; i++)
    {
        C[i] = A[i] + B[i];
    }
}

int main()
{
    // const int N = 10;
    // auto A = makeArr(N);
    // auto B = makeArr(N);
    // auto C1 = makeArr(N);
    // auto C2 = makeArr(N);

    // vector_add_host(A.data(), B.data(), C1.data(), N);
    // solve(A.data(), B.data(), C2.data(), N);
    // compareFloatArrays(C1.data(), C2.data(), N);

    return 0;
}