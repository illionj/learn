#include <unordered_map>
#include <utility>
#include <vector>
#include <iostream>
#include <map>
using std::vector;

vector<int> twoSum(vector<int> &nums,int target)
{
    vector<int> ans;
    std::unordered_map<int, int> nums_map;
    for(int i=0;i<nums.size();++i)
    {
        auto kv=nums_map.find(target-nums[i]);
        if(kv!=nums_map.end())
        {
            ans.push_back(kv->second);
            ans.push_back(i);
            break;
        }
        else {
            // nums_map[target-nums[i]]=i;
            nums_map.insert({nums[i],i});

        }

    }
    return ans;
}

int main()
{
    vector<int> nums={2,7,11,15};
    int target=9;
    auto ans=twoSum(nums, target);
    for(int i: ans)
    {
        std::cout<<i<<"\t";
    }
    std::cout<<"\n";
    std::cout<<"test\n";
}
