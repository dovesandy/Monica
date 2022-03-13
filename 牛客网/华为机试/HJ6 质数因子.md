# HJ6 质数因子
描述
功能:输入一个正整数，按照从小到大的顺序输出它的所有质因子（重复的也要列举）（如180的质因子为2 2 3 3 5 ）


数据范围： 1 ≤ n ≤ 2 x 10^{9} + 14
## 输入描述：
输入一个整数

## 输出描述：
按照从小到大的顺序输出它的所有质数的因子，以空格隔开。

## 示例1
```bash
输入：
180

输出：
2 2 3 3 5
```
## Java
```java

// 方法二
import java.util.Scanner;
public class Main {
    public static void main(String[] args){
        Scanner scan = new Scanner(System.in);
        long num = Long.parseLong(scan.next());
        getPrimer(num);
    }

    public static void getPrimer(long num){
        for (int i= 2;i <= num; i++){
            if (num % i==0){
                System.out.print(i + " ");
                getPrimer(num/i);
                break;
            }
            if (i==num){
                System.out.print( i + "");
            }
        }
    }
}
```

## JS
```js
//质数因子：首先要知道什么叫质数因子了，任何大于1的数都能被拆分成若干个质数的乘积，另外X的质因子一定小于等于根号X，即质因子的范围为2到√X
//另外还有个特殊情况，就是输入的这个数，本身就是质数，但还要排除1这个数。
let num = parseInt(readline());
let arr = []
function getCode(num){
    let i = 2,tep = num;
    while(i <= tep && i * i <= tep){
        while(num % i == 0){
            arr.push(i);
            num /= i;
        }
        ++i;
    }
    if(num != 1){
        arr.push(num);
    }

    arr.push(',');
    return arr;
}

let res = getCode(num);
console.log(res.join(',').replace(/,/gu,' '))
```