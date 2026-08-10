#include <iostream>
#include <string>
#include <cctype>
using std::string;

bool isPalindrome(string s)
{
    bool flag=true;
    int left=0;
    int right=s.size();
    while (left<right) {
        while(left<right&&!std::isalnum(s[left]))left++;
        while(left<right&&!std::isalnum(s[right]))right--;
        if(std::tolower(s[left])!=std::tolower(s[right]))
        {
            return false;
        }
        left++;
        right--;

    }


    return flag;

}

int main()
{
    string s="A man, a plan, a canal: Panama";
    auto flag=isPalindrome(s);
    std::cout<<"flag="<<flag<<"\n";
    std::cout<<"lc125\n";
    return 0;
}
