#include "cuda_check.h"
#include "fmt/core.h"
#include "utils.h"
#include <cstdio>
#include <cuda_runtime.h>

constexpr int BM = 2;
constexpr int BN = 3;
constexpr int BK = 4;
void matrix_multiplication_host(const float* A, const float* B, float* C, int M, int N, int K)
{

    for (int m = 0; m < M; ++m)
    {
        for (int k = 0; k < K; ++k)
        {
            float c_temp = 0.0f;
            for (int n = 0; n < N; ++n)
            {
                c_temp += A[m * N + n] * B[n * K + k];
            }
            C[m * K + k] = c_temp;
        }
    }
}

__global__ void matrix_multiplication_kernel_v0(const float* A, const float* B, float* C, int M,
                                                int N, int K)
{
    int col = blockDim.x * blockIdx.x + threadIdx.x;
    int row = blockDim.y * blockIdx.y + threadIdx.y;
    // printf("col=%d,row=%d\n", col, row);
    if (col < K && row < M)
    {
        float c_temp = 0.0f;
        for (int n = 0; n < N; ++n)
        {
            c_temp += A[row * N + n] * B[n * K + col];
        }
        C[row * K + col] = c_temp;
    }
}

// 任意形状tile,但是tile形状>block
__global__ void matrix_multiplication_kernel(const float* A, const float* B, float* C, int M, int N,
                                             int K)
{

    // printf("block=(%d,%d) thread=(%d,%d)\n", blockIdx.y, blockIdx.x, threadIdx.y, threadIdx.x);

    __shared__ float aTile[BM][BN];
    __shared__ float bTile[BN][BK];
    __shared__ float cTile[BM][BK];

    // 第一步是需要讲对应tile加载完毕
    const int tid = threadIdx.y * blockDim.x + threadIdx.x;
    const int blockSize = blockDim.x * blockDim.y;
    const int count = (N + BN - 1) / BN;
    for (int i = tid; i < BM * BK; i += blockSize)
    {
        int tx = i % BK;
        int ty = i / BK;
        cTile[ty][tx] = 0.0f;
    }
    __syncthreads();
    for (int c = 0; c < count; ++c)
    {

        for (int i = tid; i < BM * BN; i += blockSize)
        {
            int tx = i % BN;
            int ty = i / BN;
            int xIdx = c * BN + tx;
            int yIdx = blockIdx.y * BM + ty;
            if (yIdx < M && xIdx < N)
            {
                aTile[ty][tx] = A[yIdx * N + xIdx];
            }
            else
            {
                aTile[ty][tx] = 0.0f;
            }
        }

        for (int i = tid; i < BN * BK; i += blockSize)
        {
            int tx = i % BK;
            int ty = i / BK;
            int xIdx = blockIdx.x * BK + tx;
            int yIdx = c * BN + ty;
            if (yIdx < N && xIdx < K)
            {
                bTile[ty][tx] = B[yIdx * K + xIdx];
            }
            else
            {
                bTile[ty][tx] = 0.0f;
            }
        }
        __syncthreads();

        // 下面需要计算tile的值,但是记住 线程数有限
        for (int i = tid; i < BM * BK; i += blockSize)
        {
            int tx = i % BK;
            int ty = i / BK;
            for (int n = 0; n < BN; ++n)
            {
                cTile[ty][tx] += aTile[ty][n] * bTile[n][tx];
            }
        }
        __syncthreads();
    }
    // 现在要讲cTile拷贝到指定位置
    for (int i = tid; i < BM * BK; i += blockSize)
    {
        int tx = i % BK;
        int ty = i / BK;
        int xIdx = blockIdx.x * BK + tx;
        int yIdx = blockIdx.y * BM + ty;
        if (0)
        {
            printf("block=(%d,%d) thread=(%d,%d)\ntid=%d,i=%d,(%d,%d),idx=%d\n", blockIdx.y,
                   blockIdx.x, threadIdx.y, threadIdx.x, tid, i, yIdx, xIdx, yIdx * K + xIdx);
        }
        if (yIdx < M && xIdx < K)
        // if (1)
        {

            C[yIdx * K + xIdx] = cTile[ty][tx];
            // C[yIdx * K + xIdx] = yIdx * K + xIdx;

            // float temp = 0;
            // temp = cTile[ty][tx];
            // printf("cTile[%d][%d]=%f\n", ty, tx, temp);
            // // C[yIdx * K + xIdx] = temp;
        }
    }
}

extern "C" void solve_v0(const float* A, const float* B, float* C, int M, int N, int K)
{
    dim3 threadsPerBlock(2, 2);
    dim3 blocksPerGrid((K + threadsPerBlock.x - 1) / threadsPerBlock.x,
                       (M + threadsPerBlock.y - 1) / threadsPerBlock.y);

    matrix_multiplication_kernel_v0<<<blocksPerGrid, threadsPerBlock>>>(A, B, C, M, N, K);
    CUDA_CHECK(cudaDeviceSynchronize());
}

extern "C" void solve(const float* A, const float* B, float* C, int M, int N, int K)
{
    dim3 threadsPerBlock(2, 2);
    dim3 blocksPerGrid((K + BK - 1) / BK, (M + BM - 1) / BM);
    fmt::println("grid=({},{})", blocksPerGrid.x, blocksPerGrid.y);
    (matrix_multiplication_kernel<<<blocksPerGrid, threadsPerBlock>>>(A, B, C, M, N, K));
    CUDA_CHECK(cudaDeviceSynchronize());
}
int main()
{
    constexpr int M = 4;
    constexpr int N = 5;
    constexpr int K = 6;

    const auto A = makeRegularArr(N, M);
    const auto aSize = A.size() * sizeof(float);
    const auto B = makeRegularArr(K, N);
    const auto bSize = B.size() * sizeof(float);

    const auto C = makeRegularArr(K, M);
    const auto cSize = C.size() * sizeof(float);

    const auto C1 = makeRegularArr(K, M);

    matrix_multiplication_host(A.data(), B.data(), const_cast<float*>(C1.data()), M, N, K);

    float* A_d = nullptr;
    float* B_d = nullptr;
    float* C_d = nullptr;

    cudaMalloc((void**) &A_d, aSize);
    cudaMalloc((void**) &B_d, bSize);
    cudaMalloc((void**) &C_d, cSize);

    cudaMemcpy(A_d, A.data(), aSize, cudaMemcpyHostToDevice);
    cudaMemcpy(B_d, B.data(), bSize, cudaMemcpyHostToDevice);

    solve(A_d, B_d, C_d, M, N, K);
    cudaMemcpy((void*) C.data(), C_d, cSize, cudaMemcpyDeviceToHost);
    printf("-----------------------------------------------------------\n");
    fmt::println("c={}", C);
    fmt::println("c1={}", C1);
    compareFloatArrays(C1.data(), C.data(), K, M);
    return 0;
}