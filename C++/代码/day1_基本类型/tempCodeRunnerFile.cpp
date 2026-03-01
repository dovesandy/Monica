#include <iostream>
using namespace std;

int main() {
  cout << "🎉 Hello C++ on macOS!" << endl;

  vector<int> numbers = {1, 2, 3, 4, 5};
  cout << "Numbers: ";
  for (int num : numbers) {
    cout << num << " ";
  }
  cout << endl;
  return 0;
}