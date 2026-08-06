#include <__clang_cuda_builtin_vars.h>
#include <__clang_cuda_runtime_wrapper.h>
#include <cstdio>
#include <cuda_runtime.h>

__global__ void matrix_transpose_kernel(const float *input, float *output,
                                        int rows, int cols) {
  int col = blockDim.x * blockIdx.x + threadIdx.x;
  int row = blockDim.y * blockIdx.y + threadIdx.y;
  if (col < cols && row < rows) {
    output[col * rows + row] = input[row * cols + col];
  }
}

__global__ void matrix_transpose_kernel1(const float *input, float *output,
                                         int rows, int cols) {
  extern __shared__ float shared_mem[];
  int col = blockDim.x * blockIdx.x + threadIdx.x;
  int row = blockDim.y * blockIdx.y + threadIdx.y;

  const int TILE=blockDim.x;
  int x=blockIdx.x*TILE+threadIdx.x;
  int y=blockIdx.y*TILE+threadIdx.y;



  if(x<cols&&y<rows)
  {
    shared_mem[threadIdx.y*TILE+threadIdx.x]=input[y*cols+x];

  }
  __syncthreads();


  x=blockIdx.y*TILE+threadIdx.x;
  y=blockIdx.x*TILE+threadIdx.y;

  if(x<rows&&y<cols)
  {
    output[y*rows+x]=shared_mem[threadIdx.x*TILE+threadIdx.y];
  }



}

int main() {
  constexpr int M = 2;
  constexpr int N = 4;

  constexpr int size = N * M * sizeof(float);
  float input[M][N];
  float output_h[N][M];
  int num = 0;
  for (int m = 0; m < M; m++) {
    for (int n = 0; n < N; n++) {
      input[m][n] = num++;
    }
  }

  float *input_d = nullptr;
  float *output_d = nullptr;
  cudaMalloc((void **)&input_d, size);
  cudaMalloc((void **)&output_d, size);

  cudaMemcpy(input_d, input, size, cudaMemcpyHostToDevice);

  dim3 threadsPerBlock(16, 16);
  dim3 blocksPerGrid((N + threadsPerBlock.x - 1) / threadsPerBlock.x,
                     (M + threadsPerBlock.x - 1) / threadsPerBlock.x);
  int tileSize = threadsPerBlock.x * threadsPerBlock.y * sizeof(float);

  matrix_transpose_kernel1<<<blocksPerGrid, threadsPerBlock, tileSize>>>(
      input_d, output_d, M, N);

  cudaDeviceSynchronize();

  cudaError_t err = cudaGetLastError();
  if (err != cudaSuccess) {
    printf("%s\n", cudaGetErrorString(err));
  }

  cudaMemcpy(output_h, output_d, size, cudaMemcpyDeviceToHost);

  for (int m = 0; m < M; m++) {
    for (int n = 0; n < N; n++) {
      printf("%f ", input[m][n]);
    }
    printf("\n");
  }

  for (int n = 0; n < N; n++) {
    for (int m = 0; m < M; m++) {
      printf("%f ", output_h[n][m]);
    }
    printf("\n");
  }
  printf("test\n");
}