#include "fmt/base.h"
#include <algorithm>
#include <cstddef>
#include <cstdio>
#include <fmt/core.h>
#include <fmt/ranges.h>
#include <iterator>
#include <map>
#include <set>
#include <type_traits>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>
using namespace std;

int majorityElement_old(vector<int>& nums)
{
    int len = nums.size();
    int k = len / 2;
    unordered_map<int, int> m;
    for (int i = 0; i < nums.size(); i++)
    {
        if (m.find(nums[i]) != m.end())
        {
            m[nums[i]]++;
        }
        else
        {
            m.insert(pair<int, int>(nums[i], 1));
        }
        if (m[nums[i]] > k)
        {
            return nums[i];
        }
    }
    fmt::println("m={}", m);
    return 0;
}

int count_num(vector<int>& nums, int target, int l, int r)
{
    if (l == r)
    {
        return 0;
    }

    int count = 0;
    for (int i = l; i <= r; i++)
    {

        if (nums[i] == target)
        {
            count++;
        }
    }
    return count;
}

int me(vector<int>& nums, int l, int r)
{
    if (l == r)
    {
        return nums[l];
    }
    int mid = (l + r) / 2;
    int left = me(nums, l, mid);
    int right = me(nums, mid + 1, r);
    int flag = (r - l + 1) / 2;
    if (count_num(nums, left, l, r) > flag)
        return left;

    if (count_num(nums, right, l, r) > flag)
    {

        return right;
    }

    return -1;
}

int majorityElement(vector<int>& nums)
{
    return me(nums, 0, nums.size() - 1);
}

int main()
{
    vector<int> nums = {3, 2, 3};
    auto output = majorityElement(nums);

    fmt::println("nums={},output={}", nums, output);
    return 0;
    // int val = 2;
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
