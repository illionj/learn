#include "fmt/base.h"
#include <fmt/core.h>
#include <fmt/ranges.h>
#include <vector>

using namespace std;

void merge_old(vector<int>& nums1, int m, vector<int>& nums2, int n)
{
    if (n == 0)
        return;
    if (m == 0)
    {
        nums1 = nums2;
        return;
    }

    vector<int> pre_sum;
    pre_sum.resize(m, 0);
    vector<int> index_num2;
    index_num2.resize(n, -1);
    // for(int i=0;i<n;i++)
    // {
    //     index_num2
    // }
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < m; j++)
        {
            if (nums2[i] < nums1[j])
            {
                index_num2[i] = i + j;
                for (int k = j; k < m; k++)
                {
                    pre_sum[k]++;
                }
                break;
            }
        }
    }
    fmt::println("pre_sum={}", pre_sum);
    fmt::println("index_num2={}", index_num2);

    for (int i = m - 1; i >= 0; i--)
    {
        fmt::println("{}", i);
        nums1[i + pre_sum[i]] = nums1[i];
    }
    fmt::println("nums1_temp{}", nums1);
    int max_m = m - 1 + pre_sum[m - 1];
    fmt::println("max_m={}", max_m);
    int flag = 1;
    for (int i = 0; i < n; i++)
    {
        if (index_num2[i] != -1)
        {

            nums1[index_num2[i]] = nums2[i];
        }
        else
        {

            nums1[max_m + flag] = nums2[i];
            flag++;
        }
    }
}

void merge(vector<int>& nums1, int m, vector<int>& nums2, int n)
{
    int p = m - 1;
    int q = n - 1;
    int k = m + n - 1;

    while (k >= 0)
    {
        if (p < 0)
        {
            nums1[k] = nums2[q];
            q--;
            k--;
            continue;
        }
        if (q < 0)
        {
            nums1[k] = nums1[p];
            p--;
            k--;
            continue;
        }

        if (nums1[p] > nums2[q])
        {
            nums1[k] = nums1[p];
            p--;
        }
        else
        {
            nums1[k] = nums2[q];
            q--;
        }

        k--;
    }
}

int main()
{

    vector<int> nums1 = {4, 0, 0, 0, 0, 0};
    vector<int> nums2 = {1, 2, 3, 5, 6};
    int m = 1;
    int n = 5;

    // vector<int> nums1 = {1, 2, 3, 0, 0, 0};
    // vector<int> nums2 = {2, 5, 6};
    // int m = 3;
    // int n = 3;

    // vector<int> nums1 = {1, 0};
    // vector<int> nums2 = {2};
    // int m = 1;
    // int n = 1;
    // merge_old(nums1, m, nums2, n);

    merge(nums1, m, nums2, n);
    fmt::println("nums1={}", nums1);
}