# HJ9 提取不重复的整数
## 描述
输入一个 int 型整数，按照从右向左的阅读顺序，返回一个不含重复数字的新的整数。
保证输入的整数最后一位不是 0 。

数据范围： 1 ≤ n ≤ 10^{8}
  
## 输入描述：
输入一个int型整数

## 输出描述：
按照从右向左的阅读顺序，返回一个不含重复数字的新的整数

## 示例1
```bash
输入：
9876673

输出：
37689
```
## Java

```java
/*
使用HashSet的不重复性来判断  
- 求解每一位数字，然后注意添加到HashSet中，如果能添加进去，则说明是没有重复的，可以输出答案
- 如果无法加入成功，则说明是已经重复了，可以到下一位
*/
import java.util.*;
public class Main{
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        while(sc.hasNext()){
            // 使用HashSet来判断是否是不重复的
            HashSet<Integer> hs = new HashSet<>();
            int target = sc.nextInt();// 获取代求解的值
            while(target != 0){ // 求解每位上面的整数
                int temp = target % 10;
                if(hs.add(temp)) // 如果能加入，就是说明没有重复
                    System.out.print(temp);
                target /= 10;// 除10能去掉最右边的数字
            }
            System.out.println();
        }
    }
}
```
## JS
```js
let num = readline();
let arr = [...num];
arr = Array.from([...new Set(arr.reverse())])
num = ''
arr.forEach(e => num += e)
console.log(num)
```