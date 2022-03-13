# HJ8 合并表记录
## 描述
数据表记录包含表索引index和数值value（int范围的正整数），请对表索引相同的记录进行合并，即将相同索引的数值进行求和运算，输出按照index值升序进行输出。


提示:
0 <= index <= 11111111
1 <= value <= 100000

## 输入描述：
先输入键值对的个数n（1 <= n <= 500）
接下来n行每行输入成对的index和value值，以空格隔开

## 输出描述：
输出合并后的键值对（多行）

## 示例1
```bash
输入：
4
0 1
0 2
1 2
3 4

输出：
0 3
1 2
3 4
```
## 示例2
```bash
输入：
3
0 1
0 2
8 9

输出：
0 3
8 9
```

## Java
```java
import java.io.*;
import java.util.*;

public class Main{
    public static void main(String[] args) throws Exception{
        Scanner sc = new Scanner(System.in);
        TreeMap<Integer, Integer> map = new TreeMap<>(); // 输出结果要求有序！
       while(sc.hasNextInt()){
            int n = sc.nextInt();
            for(int i = 0; i < n; ++i){
                int a = sc.nextInt();
                int b = sc.nextInt();
                map.put(a,map.getOrDefault(a,0) + b);
            }
       }
       for (Integer i : map.keySet()) {
           System.out.println(i + " " + map.get(i));
       }
    }
}
```
## JS
```
let arr = []

while(line = readline()) {
    arr.push(line);
}

const length = arr[0];
let list = arr.slice(1, length + 1);

let newArr = [];
for (item of list) {
    let key = parseInt(item.split(' ')[0]);
    let value = parseInt(item.split(' ')[1]);
    newArr[key] = newArr[key] ? newArr[key] + value : value;
}

for (key in newArr) {
    if (newArr[key]) {
       print(key + ' ' + newArr[key]);
    }
}
```