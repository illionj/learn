#include <algorithm>
#include <iostream>
#include <vector>

using std::vector;

void merge(vector<int> &nums1,int m,vector<int> &nums2,int n)
{
    // std::copy(nums2.begin(),nums2.end(),nums1.begin()+m);
    // std::sort(nums1.begin(),nums1.end());

    int endIdx=m+n-1;
    int idx1=m-1;
    int idx2=n-1;
    for (; endIdx>=0; endIdx-=1) {
        if(idx1<0)
        {
            nums1[endIdx]=nums2[idx2];
            idx2-=1;
            continue;
        }

        if(idx2<0)
        {
            nums1[endIdx]=nums1[idx1];
            idx1-=1;
            continue;
        }



        if(nums1[idx1]>nums2[idx2])
        {
            nums1[endIdx]=nums1[idx1];
            idx1-=1;
        }else {
            nums1[endIdx]=nums2[idx2];
            idx2-=1;
        }
    }
}

int main()
{
    vector<int>nums1={1,2,3,0,0,0};
    int m=3;
    vector<int>nums2={2,5,6};
    int n=3;

    merge(nums1, m, nums2, n);

    for(auto i:nums1)
    {
        std::cout<<i<<"\t";
    }
    std::cout<<"\n";

    std::cout<<"lc88\n";
    return 0;
}
