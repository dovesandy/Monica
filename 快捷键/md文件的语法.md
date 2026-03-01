# Markdown 基本语法

语法教程地址：<https://markdown.com.cn/basic-syntax/>

## 说明

    Markdown是一种轻量级标记语言，排版语法简洁，让人们更多地关注内容本身而非排版。它使用易读易写的纯文本格式编写文档，可与HTML混编，可导出 HTML、PDF 以及本身的 .md 格式的文件。因简洁、高效、易读、易写，Markdown被大量使用，如Github、Wikipedia、简书等。

## 字号

### 字号

#### 字号

```

# 字号

### 字号

#### 字号

```

## 分行

这是第一段

这是第二段

```
这是第一段

这是第二段
```

## 有序列表

1. First item
2. Second item
3. Third item
4. Fourth item

```
1. First item
2. Second item
3. Third item
4. Fourth item
```

## 无序列表

- First item
- Second item
- Third item
- Fourth item

```
- First item
- Second item
- Third item
- Fourth item

或
* First item
* Second item
* Third item
* Fourth item

+ First item
+ Second item
+ Third item
+ Fourth item

- First item
- Second item
- Third item
    - Indented item
    - Indented item
- Fourth item

```

## 代码语法

`nano`

```

`nano`

```

## 转义反引号

``Use `code` in your Markdown file.``

```

``Use `code` in your Markdown file.``

```

## 围栏代码块
Markdown基本语法允许您通过将行缩进四个空格或一个制表符来创建代码块。如果发现不方便，请尝试使用受保护的代码块。根据Markdown处理器或编辑器的不同，您将在代码块之前和之后的行上使用三个反引号（(```）或三个波浪号（~~~）。

```
{
  "firstName": "John",
  "lastName": "Smith",
  "age": 25
}
```