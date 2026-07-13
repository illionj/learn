#include "cuda_runtime.h"
#include <cstdlib>
#include <cstdio>

inline void cudaCheck(cudaError_t err, const char *expr, const char *file,
                      int line) {
  if (err != cudaSuccess) {
    std::fprintf(stderr, "CUDA error: %s\nexpr: %s\nfile: %s\nline: %d\n",
                 cudaGetErrorString(err), expr, file, line);
    std::exit(EXIT_FAILURE);
  }
}

#define CUDA_CHECK(call) cudaCheck((call), #call, __FILE__, __LINE__)

__global__ void MatrixMulKernel(float *M, float *N, float *P, int i, int j,
                                int k) {
  int col = blockDim.x * blockIdx.x + threadIdx.x;
  int row = blockDim.y * blockIdx.y + threadIdx.y;
  if (col < k && row < i) {
    int p_index = row * k + col;
    float sum = 0;
    for (int pj = 0; pj < j; pj++) {
      int m_index = row * j + pj;
      int n_index = pj * k + col;
      sum += M[m_index] * N[n_index];
    }
    P[p_index] = sum;
  }
}

__global__ void RowMatrixMulKernel(float *M, float *N, float *P, int i, int j,
                                   int k) {
  int row = blockDim.x * blockIdx.x + threadIdx.x;
  if (row < i) {
    for (int pk = 0; pk < k; pk++) {
      int p_index = row * k + pk;
      float sum = 0;
      for (int pj = 0; pj < j; pj++) {
        int m_index = row * j + pj;
        int n_index = pj * k + pk;
        sum += M[m_index] * N[n_index];
      }
      P[p_index] = sum;
    }
  }
}



int main() {

  constexpr int i = 30;
  constexpr int j = 40;
  constexpr int k = 50;
  float *M_h = static_cast<float *>(malloc(i * j * sizeof(float)));
  float *N_h = static_cast<float *>(malloc(j * k * sizeof(float)));
  float *P_h = static_cast<float *>(malloc(i * k * sizeof(float)));

  for (int mi = 0; mi < i; mi++) {
    for (int mj = 0; mj < j; mj++) {
      int m_index = mi * j + mj;
      M_h[m_index] = 1;
    }
  }

  for (int ni = 0; ni < j; ni++) {
    for (int nj = 0; nj < k; nj++) {
      int n_index = ni * k + nj;
      N_h[n_index] = 1;
    }
  }

  float *M_d = nullptr;
  float *N_d = nullptr;
  float *P_d = nullptr;

  CUDA_CHECK(cudaMalloc((void **)&M_d, i * j * sizeof(float)));
  CUDA_CHECK(cudaMalloc((void **)&N_d, j * k * sizeof(float)));
  CUDA_CHECK(cudaMalloc((void **)&P_d, i * k * sizeof(float)));

  CUDA_CHECK(
      cudaMemcpy(M_d, M_h, i * j * sizeof(float), cudaMemcpyHostToDevice));
  CUDA_CHECK(
      cudaMemcpy(N_d, N_h, j * k * sizeof(float), cudaMemcpyHostToDevice));

  dim3 block_dim = dim3(16, 16, 1);
  dim3 grid_dim = dim3((k + block_dim.x - 1) / block_dim.x,
                       (i + block_dim.y - 1) / block_dim.y, 1);
  MatrixMulKernel<<<grid_dim, block_dim>>>(M_d, N_d, P_d, i, j, k);

  block_dim = dim3(256, 1, 1);
  grid_dim = dim3((i + block_dim.x - 1) / block_dim.x, 1, 1);
  RowMatrixMulKernel<<<grid_dim, block_dim>>>(M_d, N_d, P_d, i, j, k);

  CUDA_CHECK(cudaGetLastError());
  CUDA_CHECK(cudaDeviceSynchronize());

  cudaMemcpy(P_h, P_d, i * k * sizeof(float), cudaMemcpyDeviceToHost);
  std::printf("p[0]=%f\n", P_h[0]);

  cudaFree(M_d);
  cudaFree(N_d);
  cudaFree(P_d);
  free(M_h);
  free(N_h);
  free(P_h);

  std::printf("matMul\n");
  return 0;
}