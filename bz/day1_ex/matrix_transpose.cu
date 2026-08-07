#include <cuda_runtime.h>
#include <cstdio>


constexpr int TILE=16;
__global__ void matrix_transpose_kernel(const float *input,float *output,int rows,int cols)
{
    // int col=blockDim.x*blockIdx.x+threadIdx.x;
    // int row=blockDim.y*blockIdx.y+threadIdx.y;

    // if(row<rows&&col<cols)
    // {
    //     output[col*rows+row]=input[row*cols+col];
    //     // output[col*rows+row]=1.0f;
    // }

    int x=blockIdx.x*TILE+threadIdx.x;
    int y=blockIdx.y*TILE+threadIdx.y;

    __shared__ float sharedMem[TILE][TILE+1];
    if(y<rows&&x<cols)
    {
        sharedMem[threadIdx.y][threadIdx.x]=input[y*cols+x];
    }
    __syncthreads();

    x=blockIdx.y*TILE+threadIdx.x;
    y=blockIdx.x*TILE+threadIdx.y;

    if(x<rows&&y<cols)
    {
        // output[x*rows+y]=1.0f;
        output[y*rows+x]=sharedMem[threadIdx.x][threadIdx.y];


    }


}



int main()
{

    constexpr int M=4;
    constexpr int N=2;
    constexpr int size=M*N*sizeof(float);

    float input_h[M][N];
    float output_h[N][M];

    for(int m=0;m<M;++m)
    {
        for(int n=0;n<N;++n)
        {
            input_h[m][n]=m*N+n;
        }
    }

    float *input_d=nullptr;
    float *output_d=nullptr;

    auto err=cudaMalloc((void**)&input_d,size);
    if(err!=cudaSuccess)
    {
        printf("err=%s\n",cudaGetErrorString(err));
    }

    cudaMalloc((void**)&output_d,size);


    cudaMemcpy(input_d,input_h,size,cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(16,16);
    dim3 blocksPerGrid((N+threadsPerBlock.x-1)/threadsPerBlock.x,(M+threadsPerBlock.y-1)/threadsPerBlock.y);
    matrix_transpose_kernel<<<blocksPerGrid,threadsPerBlock>>>(input_d, output_d, M, N);

    cudaDeviceSynchronize();


    err=cudaGetLastError();
    if(err!=cudaSuccess)
    {
        printf("err=%s\n",cudaGetErrorString(err));
    }

    cudaMemcpy(output_h,output_d,size,cudaMemcpyDeviceToHost);






    for(int m=0;m<M;++m)
    {
        for(int n=0;n<N;++n)
        {
            printf("%f\t",input_h[m][n]);
        }
        printf("\n");
    }
    for(int n=0;n<N;++n)
    {
        for(int m=0;m<M;++m)
        {
            printf("%f\t",output_h[n][m]);
        }
        printf("\n");
    }




    printf("matrix_transpose\n");
    return 0;
}
