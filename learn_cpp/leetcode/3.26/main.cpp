#include "fmt/base.h"
#include <cstddef>
#include <cstdio>
#include <fmt/core.h>
#include <fmt/ranges.h>
#include <iterator>
#include <set>
#include <unordered_set>
#include <vector>
using namespace std;

int removeDuplicates(vector<int>& nums)
{
    int length = static_cast<int>(nums.size());
    if (length == 0)
    {
        return 0;
    }

    unordered_set<int> s;
    int flag = 0;
    for (int i = 0; i < length; i++)
    {
        if (s.find(nums[i]) != s.end())
            continue;
        s.insert(nums[i]);
        nums[flag] = nums[i];
        flag++;
    }

    return flag;
}

int main()
{
    vector<int> nums = {0, 0, 1, 1, 1, 2, 2, 3, 3, 4};
    auto output = removeDuplicates(nums);
    fmt::println("output={}", output);
    return 0;
    // int val = 2;
    // vector<int> nums = {};
    // int val = 0;

    // vector<int> nums = {1};
    // int val = 1;

    // vector<int> nums = {2, 2, 3};
    // int val = 2;

    // vector<int> nums1 = {1, 2, 3, 0, 0, 0};
    // vector<int> nums2 = {2, 5, 6};
    // int m = 3;
    // int n = 3;

    // vector<int> nums1 = {1, 0};
    // vector<int> nums2 = {2};
    // int m = 1;
    // int n = 1;
    // merge_old(nums1, m, nums2, n);
}
