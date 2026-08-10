#include <__clang_cuda_builtin_vars.h>
#include <__clang_cuda_runtime_wrapper.h>
#include <cstdio>
#include <cuda_runtime.h>
constexpr int M = 10;
constexpr int K = 10;
constexpr int N = 10;
constexpr int aSize = M * K * sizeof(float);
constexpr int bSize = K * N * sizeof(float);
constexpr int cSize = M * N * sizeof(float);
constexpr int TILE = 16;

void matrix_multiplication_host(const float *A, const float *B, float *C, int M,
                                int K, int N) {
  for (int m = 0; m < M; m++) {
    for (int n = 0; n < N; n++) {
      float c_temp = 0;
      for (int k = 0; k < K; k++) {
        c_temp += A[m * K + k] * B[k * N + n];
      }
      C[m * N + n] = c_temp;
    }
  }
}
__global__ void matrix_multiplication_kernel(const float *A, const float *B,
                                             float *C, int M, int K, int N) {
  int col = blockDim.x * blockIdx.x + threadIdx.x;
  int row = blockDim.y * blockIdx.y + threadIdx.y;

  if (col < N && row < M) {
    float c_temp = 0.0f;
    for (int k = 0; k < K; k++) {
      c_temp += A[row * K + k] * B[k * N + col];
    }
    C[row * N + col] = c_temp;
  }
}

__global__ void matrix_multiplication_kernel1(const float *A, const float *B,
                                              float *C, int M, int K, int N) {
  __shared__ float A_tile[TILE][TILE];
  __shared__ float B_tile[TILE][TILE];
  int tx = threadIdx.x;
  int ty = threadIdx.y;
  int bx = blockIdx.x;
  int by = blockIdx.y;
  int col = bx * TILE + tx;
  int row = by * TILE + ty;
  int count = (K + TILE - 1) / TILE;
  float c_temp = 0.0f;
  for (int i = 0; i < count; i++) {

    A_tile[ty][tx] = 0.0f;
    B_tile[ty][tx] = 0.0f;

    int A_xidx = i * TILE + tx;
    int A_yidx = row;
    int B_xidx = col;
    int B_yidx = i * TILE + ty;

    if (A_xidx < K && A_yidx < M) {

      A_tile[ty][tx] = A[A_yidx * K + A_xidx];
    }
    if (B_xidx < N && B_yidx < K) {

      B_tile[ty][tx] = B[B_yidx * N + B_xidx];
    }
    __syncthreads();

    for (int k = 0; k < TILE; k++) {
      float a_temp = A_tile[ty][k];
      float b_temp = B_tile[k][tx];
      c_temp += a_temp * b_temp;
    }
    __syncthreads();
  }
  if(col<N&&row<M)
  {
    C[row*N+col]=c_temp;
  }
}

int main() {
  float A_h[M][K];
  float B_h[K][N];
  float c_h[M][N];
  float count = 0;
  for (int m = 0; m < M; m++) {
    for (int k = 0; k < K; k++) {
      A_h[m][k] = m * K + k;
    }
  }

  for (int k = 0; k < K; k++) {
    for (int n = 0; n < N; n++) {
      B_h[k][n] = k * N + n;
    }
  }

  float *A_d = nullptr;
  float *B_d = nullptr;
  cudaMalloc((void **)&A_d, aSize);
  cudaMalloc((void **)&A_d, bSize);

  printf("matrix_multiplication\n");
  return 0;
}