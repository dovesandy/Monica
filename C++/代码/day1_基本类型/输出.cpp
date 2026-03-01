#include <iostream>
using namespace std;

int main() {
  // cout std::cout std::ostream 标准输出6流，通常连接到程序的标准输出（stdout），也就是终端/控制台。
  // << 可以用输出运算符 << 把各种类型的数据写入流
  // endl 插入一个换行符，并刷新输出缓冲区（确保所有输出都显示出来）
  cout << "🎉 Hello C++ on macOS!" << endl;

  vector<int> numbers = {1, 2, 3, 4, 5};
  cout << "Numbers: ";
  for (int num : numbers) {
    cout << num << " ";
  }
  cout << endl;
  return 0;
}