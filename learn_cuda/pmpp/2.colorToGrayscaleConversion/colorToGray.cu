
#include <cmath>
#include <cstdio>
#include <cuda_runtime.h>


// l=0.21*r+0.72*g+0.07*b;
__global__ void colortoGrayscaleConvertion(unsigned char *Pout,
                                           unsigned char *Pin, int width,
                                           int height) {

  int col = blockDim.x * blockIdx.x + threadIdx.x;
  int row = blockDim.y * blockIdx.y + threadIdx.y;
  if (col <width  && row < height) {
    auto index=row*width+col;
    int r=Pin[index*3];
    int g=Pin[index*3+1];
    int b=Pin[index*3+2];
    std::printf("r=%d,g=%d,b=%d\n",r,g,b);
    Pout[index]=0.21*r+0.72*g+0.07*b;

  }
}

int main() {

  constexpr int width = 10;
  constexpr int height = 10;
  constexpr int channel = 3;
  constexpr int img_size = width * height * channel * sizeof(unsigned char);
  unsigned char *img = (unsigned char *)std::malloc(img_size);
  for (int j = 0; j < height; j++) {

    for (int i = 0; i < width * channel; i++) {
      img[j * width * channel + i] = (j * width * channel + i) % 128;
    }
  }
  unsigned char *gray_img = (unsigned char *)std::malloc(width * height* sizeof(unsigned char));
  unsigned char *Pin;
  unsigned char *Pout;
  cudaMalloc((void **)&Pin, img_size);
  cudaMalloc((void **)&Pout, width * height* sizeof(unsigned char) );
  cudaMemcpy(Pin, img, img_size, cudaMemcpyHostToDevice);
  int block_x = 16;
  int block_y = 16;
  dim3 grid_dim =
      dim3((width + block_x - 1) / block_x, (height + block_y - 1) / block_y);
  dim3 block_dim = dim3(block_x, block_y);
  colortoGrayscaleConvertion<<<grid_dim, block_dim>>>(Pout, Pin, width, height);
  cudaDeviceSynchronize();
  cudaMemcpy(gray_img, Pout, width * height,  cudaMemcpyDeviceToHost);


  printf("test\n");
  return 0;
}