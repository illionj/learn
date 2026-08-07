#include <algorithm>
#include <iostream>
#include <vector>
using std::vector;


int removeDuplicates(vector<int>& nums)
{
    auto new_end=std::unique(nums.begin(),nums.end());
    int k=new_end-nums.begin();
    return k;

}
int removeDuplicates1(vector<int>& nums)
{
    int k=0;
    int p=0;
    int q=1;
    int len=static_cast<int>(nums.size());

    while (q<len) {
        if(nums[p]==nums[q])
        {
            q++;
            continue;
        }

        if(nums[p]!=nums[q])
        {
            p+=1;
            nums[p]=nums[q];
            q++;
            continue;
        }

    }
    k=p+1;

    return  k;
}


int main()
{
    vector<int>nums={1,2,2,3,3,3,11};
    auto k=removeDuplicates(nums);

    for(auto i:nums)
    {
        std::cout<<i<<'\t';
    }
    std::cout<<"\n"<<"k="<<k<<"\n";

    std::cout<<"lc26\n";
    return  0;
}
