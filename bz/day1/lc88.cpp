#include <iostream>

#include <vector>
#include <algorithm>
using std::vector;


/*
这一题的关键是展示一个naive
核心思路是用三个指针或者下标 一个指向第一个数组的末尾,一个指向m-1 一个指向n-1
然后不断比较m-1 和n-1 将较大者复制到数组末尾,然后数组末尾--  较大者--

注意检查边界
我犯了几个错
1.endIndex没有--
2.下标没有-1
*/

void merge(vector<int> &nums1,int m,vector<int> &nums2,int n)
{
    // std::copy(nums2.begin(),nums2.end(),nums1.begin()+m);
    // std::sort(nums1.begin(),nums1.end());

    int endIndex=m+n-1;
    int nums1End=m-1;
    int nums2End=n-1;

    for(;endIndex>=0;--endIndex)
    {
        if (nums1End>=0&&nums2End>=0) {
            if(nums1[nums1End]>nums2[nums2End])
            {
                nums1[endIndex]=nums1[nums1End];
                --nums1End;
            }
            else {
                nums1[endIndex]=nums2[nums2End];
                --nums2End;
            }
            continue;
        }

        if (nums1End<0) {
              nums1[endIndex]=nums2[nums2End];
                --nums2End;
            continue;
        }

        if(nums2End<0)
        {
            nums1[endIndex]=nums1[nums1End];
                --nums1End;
                continue;
        }


    }



}

int main()
{
    vector<int> nums1={1,2,3,0,0,0};
    vector<int>nums2={2,5,6};
    int m=3;
    int n=3;
    merge(nums1, m, nums2, n);
    for(auto i:nums1)
    {
        std:: cout<<i<<'\t';
    }
    std::cout<<"\n";
    std::cout<<"test\n";
}