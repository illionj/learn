#include "fmt/base.h"
#include <cstddef>
#include <cstdio>
#include <fmt/core.h>
#include <fmt/ranges.h>
#include <iterator>
#include <vector>

using namespace std;

int removeElement_old(vector<int>& nums, int val)
{
    int count = 0;
    const int size = static_cast<int>(nums.size());
    if (size == 0)
    {
        return 0;
    }

    int p = 0;
    int q = size - 1;

    while (q >= 0 && nums[q] == val)
    {
        q--;
        count++;
    }
    fmt::println("count={}", count);
    while (p <= q)
    {
        if (q >= 0 && nums[q] == val)
        {

            q--;
            count++;
            continue;
        }

        if (p >= 0 && q >= 0 && nums[p] == val)
        {
            int t = nums[p];
            nums[p] = nums[q];
            nums[q] = t;
            q--;
            count++;
        }
        p++;
        fmt::println("p={},q={}", p, q);
        fmt::println("count={}", count);
    }
    return size - count;
}

int removeElement(vector<int>& nums, int val)
{
    int count = 0;
    const int size = static_cast<int>(nums.size());
    if (size == 0)
    {
        return 0;
    }

    int p = 0;
    int q = size - 1;

    while (p <= q)
    {
        if (q >= 0 && nums[q] == val)
        {

            q--;
            count++;
            continue;
        }

        if (p >= 0 && q >= 0 && nums[p] == val)
        {
            int t = nums[p];
            nums[p] = nums[q];
            nums[q] = t;
            q--;
            count++;
        }
        p++;
    }
    return size - count;
}

int main()
{

    // vector<int> nums = {0, 1, 2, 2, 3, 0, 4, 2};
    // int val = 2;
    // vector<int> nums = {};
    // int val = 0;

    // vector<int> nums = {1};
    // int val = 1;

    // vector<int> nums = {2, 2, 3};
    // int val = 2;

    vector<int> nums = {0, 4, 4, 0, 4, 4, 4, 0, 2};
    int val = 4;

    int len = removeElement(nums, val);
    fmt::println("nums={},len={}", nums, len);
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