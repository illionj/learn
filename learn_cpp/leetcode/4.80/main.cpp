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
    int output = 0;
    const int len = static_cast<int>(nums.size());
    if (len == 0)
        return 0;
    if (len == 1)
        return 1;
    if (len == 2)
        return 2;

    int p = 1;
    int flag = 0;
    int q = p + 1;
    while (q < len)
    {
        if (nums[p - 1] == nums[p])
            flag = 0;
        else
            flag = 1;

        if (nums[p] == nums[q])
        {
            if (flag)
            {
                nums[p + 1] = nums[q];
                p++;
            }
        }
        else
        {
            nums[p + 1] = nums[q];
            p++;
        }

        q++;
    }
    return p + 1;
}

int main()
{
    vector<int> nums = {0, 0, 1, 1, 1, 1, 2, 3, 3};
    auto output = removeDuplicates(nums);

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
