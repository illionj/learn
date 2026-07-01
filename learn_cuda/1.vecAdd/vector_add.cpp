#include <iostream>
void vecAdd(float* A_h,float* B_h,float* C_h,int n){
    for (int i=0;i<n;++i){
        C_h[i]=A_h[i]+B_h[i];
    }
}

int main()
{
    constexpr int N=5;
    float A_h[N]={1,2,3,4,5};
    float B_h[N]={2,3,4,5,6};
    float C_h[N]={0};
    vecAdd(A_h,B_h,C_h,N);
    for(int i=0;i<N;i++){
        std::cout<<"C_h["<<i<<"]="<<C_h[i]<<'\n';
    }
}