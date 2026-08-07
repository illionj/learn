#include <algorithm>
#include <climits>
#include <iostream>
#include <utility>
#include <vector>

using std::vector;
int maxProfix(vector<int> &prices)
{
    int profit=0;
    int buyPrice=INT_MAX;
    int sellDay=0;
    struct Status
    {
        int noStockMaxProfit=0;
        int haveStockMaxProfit=0;
    };
    vector<Status> dp;
       Status s0={0,-7};

    dp.emplace_back(s0);
    const int len=static_cast<int>(prices.size());
    for(int i=1;i<len;++i)
    {
        Status s;
        auto last_s=dp[i-1];
        s.noStockMaxProfit=std::max(last_s.noStockMaxProfit,last_s.haveStockMaxProfit+prices[i]);
        s.haveStockMaxProfit=std::max(last_s.haveStockMaxProfit,-prices[i]);
        dp.push_back(s);
        std::cout<<"price="<<prices[i]<<","<<"noStockMaxProfit="<<s.noStockMaxProfit<<","<<"haveStockMaxProfit="<<s.haveStockMaxProfit<<"\n";
    }
    profit=std::max(dp.back().noStockMaxProfit,dp.back().haveStockMaxProfit);




    // for(int i=0;i<len;++i)
    // {
    //     if(prices[i]<buyPrice)
    //     {
    //         buyPrice=prices[i];
    //     }
    //     int todayProfit=prices[i]-buyPrice;
    //     if(todayProfit>profit)
    //     {
    //         profit=todayProfit;
    //     }

    // }


    // for(int i=0;i<len;++i)
    // {
    //     for(int k=i;k<len;++k)
    //     {
    //         int nowProfit=prices[k]-prices[i];
    //         if(nowProfit>profit)
    //         {
    //             profit=nowProfit;
    //             buyDay=i;
    //             sellDay=k;
    //         }
    //     }
    // }

    return  profit;
}

int main()
{
    vector<int> prices={7,1,5,3,6,4};
    auto profit=maxProfix(prices);
    std::cout<<"profit="<<profit<<'\n';
    std::cout<<"lc121\n";
    return 0;
}
