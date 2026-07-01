#include <cstdio>
#include <cstdlib>
#include "cuda_runtime.h"




inline void cudaCheck(cudaError_t err,
                      const char* expr,
                      const char* file,
                      int line)
{
    if (err != cudaSuccess) {
        std::fprintf(stderr,
            "CUDA error: %s\nexpr: %s\nfile: %s\nline: %d\n",
            cudaGetErrorString(err), expr, file, line);
        std::exit(EXIT_FAILURE);
    }
}

#define CUDA_CHECK(call) cudaCheck((call), #call, __FILE__, __LINE__)
__device__ bool checkValid(int col,int row,int w,int h)
{
    bool con1=col>=0&&col<w;
    bool con2=row>=0&&row<h;
    return con1&&con2;
}





__global__ void blurKernel(unsigned char *in,unsigned char * out,int w,int h){

    int col=blockDim.x*blockIdx.x+threadIdx.x;
    int row=blockDim.y*blockIdx.y+threadIdx.y;
    if(col<w&&row<h)
    {
        int index=row*w+col; 
        int _p=0;
        int count=0;
        for(int i=-1;i<2;i++)
        {
            for(int j=-1;j<2;j++)
            {
                int c=col+i;
                int r=row+j;
                if(checkValid(c,r,w,h))
                {
                    int patch_index=r*w+c; 
                    _p+=in[patch_index];
                    // printf("col=%d,row=%d,_p=%d\n",r,w,_p);
                    count++;
                }

            }
        }
        out[index]=static_cast<unsigned char>(_p/count);
    }
}

int main(){

    constexpr int w=30;
    constexpr int h=30;
    constexpr int _len=w*h;
    constexpr int _size=_len*sizeof(unsigned char);
    unsigned char *h_in=(unsigned char *)std::malloc(_size);
    for(int i=0;i<_len;i++)
    {
        h_in[i]=1;
        // printf("i=%d,h_in=%d\n",i,h_in[i]);
    }
    unsigned char *d_in=nullptr;
    cudaMalloc((void**)&d_in,_size);

    unsigned char *d_out=nullptr;
    cudaMalloc((void**)&d_out,_size);

    cudaMemcpy(d_in, h_in, _size, cudaMemcpyHostToDevice);

    dim3 block_dim=dim3(16,16,1);
    dim3 grid_dim=dim3((w+block_dim.x-1)/block_dim.x,(h+block_dim.y-1)/block_dim.y,1);


    blurKernel<<<grid_dim,block_dim>>>(d_in,d_out,w,h);

    CUDA_CHECK(cudaGetLastError());

    CUDA_CHECK(cudaDeviceSynchronize());


    unsigned char *h_out=(unsigned char *)std::malloc(_size);
    cudaMemcpy(h_out,d_out,_size,cudaMemcpyDeviceToHost);


    
    std::printf("h_out[0]=%d\n",h_out[0]);
    std::printf("test_blur\n");

    cudaFree(d_in);
    cudaFree(d_out);
    free(h_in);
    free(h_out);
    return 0;
}