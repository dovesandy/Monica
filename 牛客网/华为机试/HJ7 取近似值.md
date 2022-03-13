# HJ7 取近似值
## 描述
写出一个程序，接受一个正浮点数值，输出该数值的近似整数值。如果小数点后数值大于等于 0.5 ,向上取整；小于 0.5 ，则向下取整。

数据范围：保证输入的数字在 32 位浮点数范围内
## 输入描述：
输入一个正浮点数值

## 输出描述：
输出该数值的近似整数值
```bash
示例1
输入：
5.5

输出：
6

说明：
0.5>=0.5，所以5.5需要向上取整为6 
```  
## 示例2
```bash
输入：
2.499

输出：
2

说明：
0.499<0.5，2.499向下取整为2 
```
## Java
```java
import java.util.Scanner;
public class Main {

    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        double number = in.nextDouble();
        System.out.println((int)(number + 0.5));
    }
}
```

## JS
```js
//readline()方法读取的是string类型，需要用parseFloat（）等方法转换为浮点型
const num=parseFloat(readline());
//接下来用parseInt（）方法舍弃小数的特性，在数字上加上0.5再舍弃小数就可以实现四舍五入了
console.log(parseInt(num+0.5))
```