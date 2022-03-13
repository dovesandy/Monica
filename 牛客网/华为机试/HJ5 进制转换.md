# HJ5 进制转换

## 描述
写出一个程序，接受一个十六进制的数，输出该数值的十进制表示。

数据范围：保证结果在 1 ≤ n ≤ 2^{31}-1
## 输入描述：
输入一个十六进制的数值字符串。

## 输出描述：
输出该数值的十进制字符串。不同组的测试用例用\n隔开。

## 示例1
```bash
输入：
0xAA

输出：
170
```
## Java
```java
import java.io.*;
import java.util.*;

public class Main{
    public static void main(String[] args) throws Exception{
        Scanner sc = new Scanner(System.in);
        while(sc.hasNextLine()){
            String s = sc.nextLine();
            System.out.println(Integer.parseInt(s.substring(2,s.length()),16));
        }
    }
}
```

# JS
```js
// 方法1
let str;
while(str = readline()){
    // console.log(parseInt(str,16));
    console.log(Number(str));
}

// 方法2
const a = {
    'A':10,
    'B':11,
    'C':12,
    'D':13,
    'E':14,
    'F':15
}
while(str = readline()){
str = str.slice(2)
let sum = 0
if(str.length===1){
   sum =  a[str.toUpperCase()] || str
}else {
   sum = str.split('').reverse().reduce((pre, next, index) => {
    pre = a[pre.toUpperCase()] || parseInt(pre)
    next = a[next.toUpperCase()] || parseInt(next)
    return pre + next * Math.pow(16, index)
}) 
}
console.log(sum)
```