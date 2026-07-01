#include "fmt/core.h"
#include <iostream>
int main()
{
    std::cout << "test\n";
    fmt::print("test={}\n", "test");
}