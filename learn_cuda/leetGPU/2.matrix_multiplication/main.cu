#include "cuda_check.h"
#include "utils.h"
#include <nvtx3/nvToolsExt.h>
#include <random>

// host 版本
void matrix_multiplication_host(const float* A, const float* B, float* C, int M, int N, int K)
{
    for (int m = 0; m < M; m++)
    {
        for (int k = 0; k < K; k++)
        {
            int c_idx = m * K + k;
            float temp = 0.0f;
            for (int n = 0; n < N; n++)
            {
                int a_idx = m * N + n;
                int b_idx = n * K + k;
                temp += A[a_idx] * B[b_idx];
            }
            C[c_idx] = temp;
        }
    }
}

// 最简单的cuda版本
__global__ void matrix_multiplication_kernel(const float* A, const float* B, float* C, int M, int N,
                                             int K)
{
    int col = blockDim.x * blockIdx.x + threadIdx.x;
    int row = blockDim.y * blockIdx.y + threadIdx.y;
    if (col >= K || row >= M)
        return;

    float temp = 0.0f;
    for (int n = 0; n < N; n++)
    {
        int a_idx = row * N + n;
        int b_idx = n * K + col;
        temp += A[a_idx] * B[b_idx];
    }
    int c_idx = row * K + col;
    C[c_idx] = temp;
}

// 1.shared 两种格式
// 2.如何启用tile
__global__ void matrix_multiplication_kernel1(const float* A, const float* B, float* C, int M,
                                              int N, int K, int BM, int BN, int BK)
{
    extern __shared__ float shared_mem[];
    float* A_tile = shared_mem;
    float* B_tile = shared_mem + BM * BN;

    int count = (N + BN - 1) / BN;
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int bx = blockIdx.x;
    int by = blockIdx.y;
    int col = bx * blockDim.x + tx;
    int row = by * blockDim.y + ty;
    float c_temp = 0.0f;
    for (int i = 0; i < count; ++i)
    {
        int A_xidx = BN * i + tx;
        int A_yidx = row;

        int B_xidx = col;
        int B_yidx = BN * i + ty;

        A_tile[ty * BN + tx] = 0.0f;
        B_tile[ty * BK + tx] = 0.0f;
        if (A_xidx < N && A_yidx < M)
        {
            A_tile[ty * BN + tx] = A[A_yidx * N + A_xidx];
        }
        if (B_xidx < K && B_yidx < N)
        {
            B_tile[ty * BK + tx] = B[B_yidx * K + B_xidx];
        }
        __syncthreads();

        for (int pn = 0; pn < BN; ++pn)
        {
            float a_temp = A_tile[threadIdx.y * BN + pn];
            float b_temp = B_tile[pn * BK + threadIdx.x];
            c_temp += a_temp * b_temp;
        }
        __syncthreads();
    }
    if (row < M && col < K)
    {
        C[row * K + col] = c_temp;
    }
}

// 支持任意形状  不考虑性能 但是tile至少要大于block
__global__ void matrix_multiplication_kernel2(const float* A, const float* B, float* C, int M,
                                              int N, int K, int BM, int BN, int BK)
{
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int bx = blockIdx.x;
    int by = blockIdx.y;

    extern __shared__ float shared_mem[];
    float* A_tile = shared_mem;
    float* B_tile = shared_mem + BM * BN;

    int A_tile_size = BM * BN;
    int B_tile_size = BN * BK;
    int tid = ty * blockDim.y + tx;
    float c_temp = 0.0f;
    int blockSize = blockDim.x * blockDim.y;
    int count = (N + BN - 1) / BN;
    int row = by * blockDim.y + ty;
    int col = bx * blockDim.x + tx;
    for (int i = 0; i < count; i++)
    {

        for (int p = tid; p < A_tile_size; p += blockSize)
        {
            int _x = p % BN;
            int _y = p / BN;
            A_tile[p] = 0.0f;
            int A_xidx = BN * i + _x;
            int A_yidx = BM * i + _y;
            if (A_xidx < N && A_yidx < M)
            {
                A_tile[p] = A[A_yidx * N + A_xidx];
            }
        }

        for (int p = tid; p < B_tile_size; p += blockSize)
        {
            int _x = p % BK;
            int _y = p / BK;
            int B_xidx = BK * i + _x;
            int B_yidx = i * BN + _y;
            B_tile[p] = 0.0f;
            if (B_xidx < K && B_yidx < N)
            {
                B_tile[p] = B[B_yidx * K + B_xidx];
            }
        }
        __syncthreads();

        for (int q = 0; q < BN; ++q)
        {
            float a_temp = A_tile[threadIdx.y * BN + q];
            float b_temp = B_tile[q * BN + threadIdx.x];
            c_temp += a_temp * b_temp;
        }
        __syncthreads();
    }
    if (col < K && row < M)
    {
        C[row * K + col] = c_temp;
    }
}

// A, B, C are device pointers (i.e. pointers to memory on the GPU)
extern "C" void solve(const float* A, const float* B, float* C, int M, int N, int K, int BM, int BN,
                      int BK)
{
    dim3 threadsPerBlock(BM, BK);
    dim3 blocksPerGrid((K + threadsPerBlock.x - 1) / threadsPerBlock.x,
                       (M + threadsPerBlock.y - 1) / threadsPerBlock.y);

    float* A_d = nullptr;
    float* B_d = nullptr;
    float* C_d = nullptr;

    cudaMalloc((void**) &A_d, sizeof(float) * M * N);
    cudaMalloc((void**) &B_d, sizeof(float) * N * K);
    cudaMalloc((void**) &C_d, sizeof(float) * M * K);

    cudaMemcpy(A_d, A, sizeof(float) * M * N, cudaMemcpyHostToDevice);
    cudaMemcpy(B_d, B, sizeof(float) * N * K, cudaMemcpyHostToDevice);

    size_t shared_bytes = (BM * BN + BN * BK) * sizeof(float);

    nvtxRangePush("matrix multiply");
    matrix_multiplication_kernel2<<<blocksPerGrid, threadsPerBlock, shared_bytes>>>(
        A_d, B_d, C_d, M, N, K, BM, BN, BK);
    cudaDeviceSynchronize();
    nvtxRangePop();

    cudaMemcpy(C, C_d, sizeof(float) * M * K, cudaMemcpyDeviceToHost);
}

int main()
{

    const int M = 35;
    const int N = 45;
    const int K = 61;

    const int BM = 16;
    const int BN = 17;
    const int BK = 16;

    const auto A_h = makeRandArr(M, N);
    const auto B_h = makeRandArr(N, K);
    // std::vector<float> A_h;
    // A_h.resize(M * N);
    // for (int i = 0; i < M * N; i++)
    // {
    //     A_h[i] = static_cast<float>(i + 1);
    // }
    // std::vector<float> B_h;
    // B_h.resize(N * K);
    // for (int i = 0; i < N * K; i++)
    // {
    //     B_h[i] = static_cast<float>(i + 1);
    // }

    fmt::println("A_h={}", B_h[0]);
    // fmt::println("A_h={}", B_h[16 * K + 16]);
    auto C_h1 = makeRandArr(M, K);
    auto C_h2 = makeRandArr(M, K);
    matrix_multiplication_host(A_h.data(), B_h.data(), C_h1.data(), M, N, K);
    solve(A_h.data(), B_h.data(), C_h2.data(), M, N, K, BM, BN, BK);

    compareFloatArrays(C_h1.data(), C_h2.data(), M, K);
}