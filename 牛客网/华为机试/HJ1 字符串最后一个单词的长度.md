
# HJ1 字符串最后一个单词的长度

## 描述

计算字符串最后一个单词的长度，单词以空格隔开，字符串长度小于5000。（注：字符串末尾不以空格为结尾）

## 输入描述：
输入一行，代表要计算的字符串，非空，长度小于5000。

## 输出描述：
输出一个整数，表示输入字符串最后一个单词的长度。

## 示例1
```bash
输入：
hello nowcoder
输出：
8
说明：
最后一个单词为nowcoder，长度为8
```
## 解题
### java
```java
// 方法一: 系统函数
public static void main(String[] args){
    Scanner sc = new Scanner(System.in);
    String str = sc.nextLine();
    String[] s = str.split(" "); //正则表达式实用性更强( str.split("\\s+"))
    int length = s[s.length - 1].length();
    System.out.println(length);
}

// 方法二: 反过来打印
public static void main(String[] args) {
    Scanner sc = new Scanner(System.in);
    String str = sc.nextLine();
    int length = str.length();
    int count = 0;
    for (int i = length - 1; i >= 0; i--) {
        if (str.charAt(i)==' ') { // 或者 if (str.substring(i, i + 1).equals(" ")) {
            break;
        }
        count++;
    }
    System.out.println(count);
}
```

### JavaScript
```javascript
const line = readline();

function getLastWordLength(str) {
    let i = str.length - 1;

    while (i > -1) {
        if (str[i] === ' ') break;
        i -= 1;
    }

    return str.length - 1 - i;
}

console.log(getLastWordLength(line));

```


