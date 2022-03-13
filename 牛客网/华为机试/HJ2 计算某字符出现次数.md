# HJ2 计算某字符出现次数

## 描述

写出一个程序，接受一个由字母、数字和空格组成的字符串，和一个字符，然后输出输入字符串中该字符的出现次数。（不区分大小写字母）

数据范围：1≤n≤1000 
## 输入描述：

第一行输入一个由字母和数字以及空格组成的字符串，第二行输入一个字符。
## 输出描述：

输出输入字符串中含有该字符的个数。（不区分大小写字母）

## 示例
```ABCabc
输入：
Abash
A
输出：
2
```
## Java
```java
import java.util.*;
public class Main{
public static void main(String[] args){
    Scanner sc = new Scanner(System.in);
    String str =sc.nextLine().toLowerCase();
    String s = sc.nextLine();
    System.out.print(str.length()-str.replaceAll(s,"").length());
}
}
```

## JS
```js
// 字符串切割方法
var str = readline().toLowerCase()
var key = readline().toLowerCase()

var count = 0;

console.log(str.split(key).length -1)

// 正则表达式方法
const str = readline();
const key = readline();
(() => {
    const matchReg = new RegExp(`${key}`, 'ig')
    const matchRes = str.match(matchReg) || []
    console.log(matchRes.length)
})()
// 循环查找方法
const str = readline()
const ch = readline()
var num = 0
const str_arr = str.split('')
str_arr.forEach(item => {
    if(item.toLowerCase() === ch.toLowerCase()) num ++
})
console.log(num)
```

