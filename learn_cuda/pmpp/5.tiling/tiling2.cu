
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>
#include <random>

constexpr int M = 3171;
constexpr int K = 2312;
constexpr int N = 1733;
constexpr int A_BYTE_SIZE = M * K * sizeof(float);
constexpr int B_BYTE_SIZE = K * N * sizeof(float);
constexpr int C_BYTE_SIZE = M * N * sizeof(float);
constexpr int BX = 16;
constexpr int BY = 16;
inline void cudaCheck(cudaError_t err, const char *expr, const char *file,
                      int line) {
  if (err != cudaSuccess) {
    std::fprintf(stderr, "CUDA error: %s\nexpr: %s\nfile: %s\nline: %d\n",
                 cudaGetErrorString(err), expr, file, line);
    std::exit(EXIT_FAILURE);
  }
}

#define CUDA_CHECK(call) cudaCheck(call, #call, __FILE__, __LINE__)

void check(float *matA, float *matB, float *matC) {
  for (int i = 0; i < M; i++) {
    for (int j = 0; j < N; j++) {
      double pvalue = 0.0f;
      for (int k = 0; k < K; k++) {
        pvalue += static_cast<double>(matA[i * K + k]) *
                  static_cast<double>(matB[k * N + j]);
      }
      matC[i * N + j] = static_cast<float>(pvalue);
    }
  }
}

__global__ void tiling(float *matA, float *matB, float *matC) {

  //   int _col = blockDim.x * blockIdx.x + threadIdx.x;
  //   int _row = blockDim.y * blockIdx.y + threadIdx.y;
  int flag = false;
  //   if (_col == 1 && _row == 0)
  //     flag = true;

  __shared__ float Atile[BY][BX];
  __shared__ float Btile[BY][BX];
  // 第一步是要把数据取出来
  // 第二步是将这部分数据作用于所有受影响的矩阵元素(循环)
  // 第三步 循环

  // 横放和竖放,需要的最大数量
  int loop_k_x = (K + BX - 1) / BX;
  int loop_k_y = (K + BY - 1) / BY;
  int loop_k = max(loop_k_x, loop_k_y);
  if (flag) {
    printf("loop_k=%d,loop_k_x=%d,loop_k_y=%d \n", loop_k, loop_k_x, loop_k_y);
  }

  double pvalue = 0.0f;
  int bx_idx = blockIdx.x;
  int by_idx = blockIdx.y;
  int bcol = bx_idx * BX;
  int brow = by_idx * BY;
  int tcol = threadIdx.x;
  int trow = threadIdx.y;

  // 开始循环
  for (int bk = 0; bk < loop_k; bk++) {
    // 当前线程所在的block
    // ,后续需要matA的第y行上所有block和matB第x列上的所有block

    // 这里来解释一些怎么来的
    /*
    正如前面所说,计算一个matC的结果tile也就是mat的xy block
    需要需要matA的第y行上所有block和matB第x列上的所有block
    对于matA来说这y行的所有block的row都是不变的,都和matc 结果tile的row相同
    对于matB来说这x列的所有block的col都是不变的,都和matc 结果tile的col相同

    然后是tcol和trow
    它俩是block内部的线程坐标block是threadIdx

    所以当前开始填充__shared__的时候
    我们首先要知道Atile和Btile的具体问题,也就是第i行j列
    接着是从matA和matB中获取对应位置的数据
    matA
    行由两部分组成 1.block自身所在行的thread起始行,也就是brow  2.block中线程的纵向偏移,也就是trow
    列也由两部部分组成 1.当前此行上所有block的循环的起始行,也就是bk*BX 2.bk下线程的横向偏移,也就是tcol

    matB 同理 行两部分 1.
    当前此列上所有block的循环也就是bk*BY  2.bk下线程的纵向偏移 也就是trow
    列两部分  1.不变的bcol列  2.col列中的横向线程偏移

    最后,补齐约束限制
    */

    int aIdx = (brow + trow) * K + bk * BX + tcol;
    int bIdx = (bk * BY + trow) * N + bcol + tcol;
    auto condition1 = bk * BX + tcol < K && brow + trow < M;
    auto condition2 = bk * BY + trow < K && bcol + tcol < N;
    if (flag) {
      printf("condition1=%d,condition2=%d \n", condition1, condition2);
    }
    if (condition1) {
      Atile[trow][tcol] = matA[aIdx];

    } else {
      Atile[trow][tcol] = 0.0f;
    }
    if (condition2) {

      Btile[trow][tcol] = matB[bIdx];
    } else {

      Btile[trow][tcol] = 0.0f;
    }

    __syncthreads();
    // 完成赋值后,进行同步
    // 开始计算

    if (flag) {
      printf("a01=%f\n", Atile[0][1]);
      printf("b10=%f\n", Btile[1][0]);
    }

    for (int i = 0; i < BX; i++) {
      pvalue += static_cast<double>(Atile[threadIdx.y][i]) *static_cast<double>( Btile[i][threadIdx.x]);

      //   if (flag) {
      //     printf("i=%d,tx=%d,ty=%d \n",i,threadIdx.x,threadIdx.y);
      //     printf(
      //         "Atile[threadIdx.y][i]=%f, Btile[i][threadIdx.x]=%f,pvalue=%f
      //         \n", Atile[threadIdx.y][i], Btile[i][threadIdx.x], pvalue);
      //   }
    }
    __syncthreads();
    if (flag) {
      printf("pvalue=%f \n", pvalue);
    }
  }
  if (brow + trow < M && bcol + tcol < N) {
    matC[(brow + trow) * N + bcol + tcol] = static_cast<float>(pvalue);
  }
}
void test_tiling() {
  float *matA_h = static_cast<float *>(malloc(A_BYTE_SIZE));
  float *matB_h = static_cast<float *>(malloc(B_BYTE_SIZE));
  float *matC_h = static_cast<float *>(malloc(C_BYTE_SIZE));
  float *matC_c = static_cast<float *>(malloc(C_BYTE_SIZE));
  cudaError_t err = cudaSuccess;

  std::random_device rd;
  std::mt19937 gen(rd());
  std::uniform_real_distribution<float> dis(-100, 100.0);

  for (int i = 0; i < M; i++) {
    for (int j = 0; j < K; j++) {
      int index = i * K + j;
      matA_h[index] = dis(gen);
      ;
    }
  }
  for (int i = 0; i < K; i++) {
    for (int j = 0; j < N; j++) {
      int index = i * N + j;
      matB_h[index] = dis(gen);
    }
  }

  check(matA_h, matB_h, matC_c);
  float *matA_d = nullptr;
  float *matB_d = nullptr;
  float *matC_d = nullptr;

  CUDA_CHECK(cudaMalloc((void **)&matA_d, A_BYTE_SIZE));
  CUDA_CHECK(cudaMalloc((void **)&matB_d, B_BYTE_SIZE));
  CUDA_CHECK(cudaMalloc((void **)&matC_d, C_BYTE_SIZE));

  cudaMemcpy(matA_d, matA_h, A_BYTE_SIZE, cudaMemcpyHostToDevice);
  cudaMemcpy(matB_d, matB_h, B_BYTE_SIZE, cudaMemcpyHostToDevice);

  dim3 block_dim = dim3(BX, BY, 1);
  dim3 grid_dim = dim3((N + block_dim.x - 1) / block_dim.x,
                       (M + block_dim.y - 1) / block_dim.y, 1);
  tiling<<<grid_dim, block_dim>>>(matA_d, matB_d, matC_d);

  cudaDeviceSynchronize();
  err = cudaGetLastError();
  if (err != cudaSuccess) {
    printf("err1=%s\n  line=%d", cudaGetErrorString(err), __LINE__);
    exit(0);
  }

  cudaMemcpy(matC_h, matC_d, C_BYTE_SIZE, cudaMemcpyDeviceToHost);

  for (int i = 0; i < M; i++) {
    for (int j = 0; j < N; j++) {
      int idx = i * N + j;
      float cpu = matC_c[idx];
      float gpu = matC_h[idx];
      auto rtol = 1e-3f;
      auto atol = 1e-3f;
      float diff = std::abs(cpu - gpu);
      float tol = atol + rtol * std::fabs(cpu);

      if (!std::isfinite(cpu) || !std::isfinite(gpu) || diff > tol) {
        printf("matC_c=%f,matC_h=%f\n", matC_c[i * N + j], matC_h[i * N + j]);
        printf("i=%d,j=%d\n", i, j);
        exit(0);
      }
    }
  }

  std::printf("计算正确\n");

  cudaFree(matA_d);
  cudaFree(matB_d);
  cudaFree(matC_d);

  free(matA_h);
  free(matB_h);
  free(matC_h);
  free(matC_c);
}

int main() {
  test_tiling();
  printf("test_tiling2\n");
  return 0;
}