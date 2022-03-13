# HJ4 字符串分隔

## 描述

- 连续输入字符串，请按长度为8拆分每个输入字符串并进行输出；
- 长度不是8整数倍的字符串请在后面补数字0，空字符串不处理。
## 输入描述：

连续输入字符串(每个字符串长度小于等于100)
## 输出描述：

依次输出所有分割后的长度为8的新字符串
## 示例1
```bash
输入：
abc

输出：
abc00000
```

## Java
```java
/*
思路

需要输入字符串，用到Scanner和hasNext()。
（1）建立 Scanner sc = new Scanner(System.in);
（2）判断有无输入用sc.hasNext().接收字符串使用sc.nextLine().
一次性接受全部的字符串，对8取余，获知需要补0的位数。使用StringBuilder中的append()函数进行字符串修改，别忘了toString()。
字符串缓冲区的建立：StringBuilder sb = new StringBuilder();
输出时，截取前8位进行输出，并更新字符串。用到str.substring()函数：
（1）str.substring(i)意为截取从字符索引第i位到末尾的字符串。
（2）str.substring(i,j)意为截取索引第i位到第（j-1）位字符串。包含i，不包含j。
*/

import java.util.*;
public class Main{
    public static void main(String[] args){
        Scanner sc = new Scanner(System.in);

        while(sc.hasNext()){
            String str = sc.nextLine();
            StringBuilder sb = new StringBuilder();//牢记字符串缓冲区的建立语法
            sb.append(str);//字符串缓冲区的加入
            int size = str.length();
            int addZero = 8 - size%8;//addzero的可能值包括8
            while((addZero > 0)&&(addZero<8)){//注意边界调节，避免addzero=8
                sb.append("0");//使用‘’或“”都可
                addZero--;
            }
            String str1 = sb.toString();
            while(str1.length()>0){
                System.out.println(str1.substring(0,8));
                str1 = str1.substring(8);
            }

        }
    }
}

// 方法2
import java.util.Scanner;
/**
 * @author lxg
 * @description 字符串分割
 * @date 2021/9/26
 */
public class Main {
    public static void main(String[] args) {
        Scanner input = new Scanner(System.in);
        while(input.hasNextLine()){
            String s = input.nextLine();
            split(s);
        }
    }

    public static void split(String s){
        while(s.length()>=8){
            System.out.println(s.substring(0,8));
            s=s.substring(8);
        }
        if(s.length()<8 && s.length()>0){
            s+="00000000";
            System.out.println(s.substring(0,8));
        }
    }
}


```
## JS
```js
let line
while (line = readline()) {
    const overNumber = line.length % 8
    const result = line.concat(new String("0").repeat(overNumber ? 8 - overNumber : 0))
    for (let i = 0; i < result.length;) {
        console.log(result.substring(i, i += 8))
    }
}
```