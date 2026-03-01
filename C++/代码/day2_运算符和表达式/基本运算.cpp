#include <iostream>
using namespace std;

int main() {
  int a = 10;
  int b = 3;
  cout << "基本运算符和表达式" << endl;
  cout << "a + b = " << a + b << endl;                // 加法
  cout << "a - b = " << a - b << endl;                // 减法
  cout << "a * b = " << a * b << endl;                // 乘法
  cout << "a / b = " << a / b << endl;                // 整数除法
  cout << "a % b = " << a % b << endl;                // 取模
  cout << "a / (float)b = " << a / (float)b << endl;  // 浮点数除法
  cout << "a++ = " << a++ << ", a = " << a << endl;   // 后置递增
  cout << "++b = " << ++b << ", b = " << b << endl;   // 前置递增
  cout << "a-- = " << a-- << ", a = " << a << endl;   // 后置递减
  cout << "--b = " << --b << ", b = " << b << endl;   // 前置递减
  cout << "a += 5 -> a = " << (a += 5) << endl;       // 复合赋值
  cout << "b *= 2 -> b = " << (b *= 2) << endl;       // 复合赋值
  cout << "a == b: " << (a == b) << endl;             // 相等
  cout << "a != b: " << (a != b) << endl;             // 不相等
  cout << "a > b: " << (a > b) << endl;               // 大于
  cout << "a < b: " << (a < b) << endl;               // 小于
  cout << "a >= b: " << (a >= b) << endl;             // 大于等于
  cout << "a <= b: " << (a <= b) << endl;             // 小于等于
  cout << "(a > b) && (a < 20): " << ((a > b) && (a < 20)) << endl;  // 逻辑与
  cout << "(a < b) || (b < 10): " << ((a < b) || (b < 10)) << endl;  // 逻辑或
  cout << "!(a == b): " << (!(a == b)) << endl;
  cout << "三元运算符: " << (a > b ? a : b) << endl;       // 三元运算符
  cout << "sizeof(a): " << sizeof(a) << " bytes" << endl;  // sizeof 运算符
  cout << "sizeof(b): " << sizeof(b) << " bytes" << endl;  // sizeof 运算符

  int isSundy = false;
  cout << "isSundy: " << isSundy << endl;  // 布尔值输出，false 输出 0
  isSundy = true;
  cout << "isSundy: " << isSundy << endl;       // 布尔值输出，true 输出 1
  cout << "isSundy取反: " << !isSundy << endl;  // 取反

  int right = true;
  int wrong = false;
  cout << "right && wrong: " << (right && wrong) << endl;  // 逻辑与
  cout << "right || wrong: " << (right || wrong) << endl;  // 逻辑或
  cout << "right ^ wrong: " << (right ^ wrong)
       << endl;  // 异或，两个操作数相同则结果为 false，否则为 true
  short s = 10;
  int i = s;  // short 自动提升为 int

  // 浮点数转换

  int integer = 10;
  double decimal = integer;  // int 自动提升为 double
  cout << "integer: " << integer << ", decimal: " << decimal
       << endl;  // 输出: integer: 10, decimal: 10.0

  // 混合类型运算
  int a1 = 10;
  double b1 = 3.5;
  double result = a1 + b1;                 // int 自动提升为 double
  cout << "a1 + b1 = " << result << endl;  // 输出: a + b = 13.5

  return 0;
}