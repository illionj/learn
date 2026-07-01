
#include <cstddef>
#include <cstdio>
#include <cuda_runtime.h>

inline void cudaCheck(cudaError_t err, const char *expr, const char *file,
                      int line) {
  if (err != cudaSuccess) {
    std::fprintf(stderr, "CUDA error: %s\nexpr: %s\nfile: %s\nline: %d\n",
                 cudaGetErrorString(err), expr, file, line);
    std::exit(EXIT_FAILURE);
  }
}

#define CUDA_CHECK(call) cudaCheck(call, #call, __FILE__, __LINE__)

constexpr int WIDTH = 4;
constexpr int SIZE = WIDTH * WIDTH * sizeof(float);
constexpr int BX = 2;
constexpr int BY = 2;





__global__ void tileMat(float *matA, float *matB, float *matC) {
  __shared__ float Adata[BY][BX];
  __shared__ float Bdata[BY][BX];

  int col = blockDim.x * blockIdx.x + threadIdx.x;
  int row = blockDim.y * blockIdx.y + threadIdx.y;

  bool flag = false;
  if (col == 0 && row == 0)
    flag = true;

  float pvalue = 0.0;

  for (int tile = 0; tile < blockDim.x; tile++) {

    auto offsetX = tile * BX;
    auto offsetY = tile * BY;
    Adata[threadIdx.y][threadIdx.x] = matA[row * WIDTH + threadIdx.x + offsetX];
    Bdata[threadIdx.y][threadIdx.x] =
        matB[(threadIdx.y + offsetY) * WIDTH + col];
    __syncthreads();
    if (flag) {

      for (int i = 0; i < BY; i++) {
        for (int j = 0; j < BX; j++) {
          printf("Adata[%d][%d]=%f\n", i, j, Adata[i][j]);
          printf("Bdata[%d][%d]=%f\n", i, j, Bdata[i][j]);
        }
      }
    }

    for (int k = 0; k < BY; k++) {
      pvalue += Adata[threadIdx.y][k] * Bdata[k][threadIdx.x];
    }
    __syncthreads();
    if (flag) {
      printf("pvalue=%f\n", pvalue);
    }
  }
  if (col < WIDTH && row < WIDTH) {
    matC[row * WIDTH + col] = pvalue;
  }
}

void test_tiling() {

  auto matA_h = static_cast<float *>(malloc(SIZE));
  auto matB_h = static_cast<float *>(malloc(SIZE));
  auto matC_h = static_cast<float *>(malloc(SIZE));

  float *matA_d = nullptr;
  float *matB_d = nullptr;
  float *matC_d = nullptr;

  CUDA_CHECK(cudaMalloc((void **)&matA_d, SIZE));
  CUDA_CHECK(cudaMalloc((void **)&matB_d, SIZE));
  CUDA_CHECK(cudaMalloc((void **)&matC_d, SIZE));

  for (int i = 0; i < WIDTH; i++) {
    for (int j = 0; j < WIDTH; j++) {
      matA_h[WIDTH * i + j] = 1;
      matB_h[WIDTH * i + j] = 2;
    }
  }

  cudaMemcpy(matA_d, matA_h, SIZE, cudaMemcpyHostToDevice);
  cudaMemcpy(matB_d, matB_h, SIZE, cudaMemcpyHostToDevice);

  dim3 block_dim = dim3(BX, BY, 1);
  dim3 grid_dim = dim3((WIDTH + block_dim.x - 1) / block_dim.x,
                       (WIDTH + block_dim.y - 1) / block_dim.y, 1);

  tileMat<<<grid_dim, block_dim>>>(matA_d, matB_d, matC_d);

  cudaMemcpy(matC_h, matC_d, SIZE, cudaMemcpyDeviceToHost);

  std::printf("matC=%f,%f\n", matC_h[14], matC_h[15]);

  cudaFree(matA_d);
  cudaFree(matB_d);
  cudaFree(matC_d);

  free(matA_h);
  free(matB_h);
  free(matC_h);
}




int main() {
  test_tiling();
  std::printf("tiling\n");
}