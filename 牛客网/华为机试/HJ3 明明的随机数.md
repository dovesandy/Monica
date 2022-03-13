# HJ3 明明的随机数
## 描述

明明生成了N个1到500之间的随机整数。请你删去其中重复的数字，即相同的数字只保留一个，把其余相同的数去掉，然后再把这些数从小到大排序，按照排好的顺序输出。
数据范围：1≤n≤1000  ，输入的数字大小满足 1≤val≤500

## 输入描述：

第一行先输入随机整数的个数 N 。 接下来的 N 行每行输入一个整数，代表明明生成的随机数。 具体格式可以参考下面的"示例"。
## 输出描述：

输出多行，表示输入数据处理后的结

## 示例
```bash
输入：
3
2
2
1
输出：
1
2

说明：

输入解释：
第一个数字是3，也即这个小样例的N=3，说明用计算机生成了3个1到1000之间的随机整数，接下来每行一个随机数字，共3行，也即这3个随机数字为：
2
2
1

所以样例的输出为：
1
2 
```

# Java
```java
/*
题目有两个要求：
- 去重
- 排序
思路：这不就是TreeSet的数据结构嘛！
*/
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        //获取个数
        int num = sc.nextInt();
        //创建TreeSet进行去重排序
        TreeSet set = new TreeSet();
        //输入
        for(int i =0 ; i < num ;i++){
            set.add(sc.nextInt());
        }

        //输出
        Iterator iterator = set.iterator();
        while (iterator.hasNext()){
            System.out.println(iterator.next());
        }
    }
}

// 方法2
import java.util.Scanner;
import java.util.Arrays;

public class Main{
    public static void main(String[] args){
        Scanner in = new Scanner(System.in);
        while(in.hasNext()){
            int count = in.nextInt();    //随机数总数
            int[] data = new int[count];
            for(int i=0; i < count; i++)    //读入生成的随机数
                data[i] = in.nextInt();
            
            Arrays.sort(data);    //使用库函数排序
            System.out.println(data[0]);    //打印排序后的第一个数（必不重复）
            for(int i=1; i < count; i++){    //打印其他数字，需与前面数字比较，不重复才能打印
                if(data[i] != data[i-1])
                    System.out.println(data[i]);
            }
        }
    }
}
```

## JS
```js
let num
const randomRepeat = n => {
    let randomArray = []
    while(n = readline()) {
        for(let i = 0; i < n; i++) {
            randomArray.push(parseInt(readline()))
        }
    }
    /*
    **利用Set的特性将数组放入其中去重
    **使用原生sort函数进行排序
    **这里直接用join加换行符解决输出了
    */
    return [...new Set(randomArray)].sort((a, b) => (a - b)).join('\n')
}
console.log(randomRepeat(num))
```
