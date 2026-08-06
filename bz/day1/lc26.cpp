#include <algorithm>
#include <iostream>
#include <vector>
using std::vector;

/*
 首先掌握naive方式,直接去重 std::unique

 原题思路就是准备快慢指针,一个指向已经完成去重的位置,一个执行检查是否为重复的位置
 如果发现重复的地方就q就进入下一个
 如果发现不重复,则将q的数值拷贝到将p的下一个位置,然后p++
*/

int removeDuplicates(vector<int> &nums)
{
    int k=0;
    // auto new_end=std::unique(nums.begin(),nums.end());
    // k=nums.end()-new_end;
    // std::fill(new_end,nums.end(),0);
    int p=0;
    int q=1;
    int size=static_cast<int>(nums.size());
    while (q<size) {
        if(nums[p]==nums[q])
        {
            ++q;
            continue;
        }
        else {
            p+=1;
            nums[p]=nums[q];
            ++q;
            continue;
        }


    }
    k=p+1;


    return k;

}


int main()
{

    // vector<int> nums={1,1,2};
    vector<int> nums={1,1,1,3,3,3,6,6,6};
    auto k=removeDuplicates(nums);
    std::cout<<"k="<<k<<"\n";
    for(const auto i:nums)
    {
        std::cout<<i<<'\t';
    }
    std::cout<<"\n";
    std::cout<<"test\n";
}
