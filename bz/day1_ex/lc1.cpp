#include <iostream>
#include <unordered_map>
#include <vector>
#include <map>

using std::vector;

vector<int> twoSum(vector<int> &nums,int target)
{
    vector<int> ans;
    std::unordered_map<int, int>mp;
    int len=static_cast<int>(nums.size());
    for(int i=0;i<len;++i)
    {
        auto kv=mp.find(target-nums[i]);
        if(kv!=mp.end())
        {
            ans.insert(ans.end(),{kv->second,i});
            break;
        }else {
            mp.insert({nums[i],i});
        }

    }
    return ans;
}

int main()
{
    vector<int>nums={2,7,11,18};
    int target=9;
    auto ans=twoSum(nums, target);
    for(auto i:ans)
    {
        std::cout<<i<<"\t";
    }
    std::cout<<"\n";
    std::cout<<"lc1\n";
}
