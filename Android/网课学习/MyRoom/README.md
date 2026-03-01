# MyRoom - Room 示例项目

这是一个用于教学的 Android 示例模块，演示如何使用 Room 进行本地持久化存储（增、删、改、查）。项目使用 Jetpack Compose 实现简单的 UI，包含一个 `RoomStore` 用于封装常用的 CRUD 操作。

主要文件：

- `app/src/main/java/com/lingchongsen/myroom/model/User.kt`：Room 实体类
- `app/src/main/java/com/lingchongsen/myroom/dao/UserDao.kt`：DAO（数据访问对象）
- `app/src/main/java/com/lingchongsen/myroom/db/AppDatabase.kt`：Room 数据库单例
- `app/src/main/java/com/lingchongsen/myroom/RoomStore.kt`：封装的 Repository（增删改查方法）
- `app/src/main/java/com/lingchongsen/myroom/MainActivity.kt`：Compose UI 与交互逻辑

快速开始

1. 在 Android Studio 中打开项目并同步 Gradle。
2. 运行 `:MyRoom:app` 模块。
3. 在 UI 中输入用户名、年龄、邮箱，点击 `插入【增】` 保存数据，点击 `用户列表` 中的条目选择进行更新或删除操作。

关于 GitHub 表情（Emoji）使用说明

在 GitHub 的 README、Issue、PR 或评论中可以通过短代码（shortcode）插入 emoji，使文档更直观友好。

常见用法示例：

- `:sparkles:` → ✨
- `:rocket:` → 🚀
- `:bug:` → 🐛
- `:white_check_mark:` → ✅
- `:x:` → ❌
- `:memo:` → 📝

你可以直接在 Markdown 中写这些短代码，GitHub 会渲染成对应的表情。例如：

```
项目完成： :white_check_mark: 添加 Room 支持
```

会显示为：

项目完成： ✅ 添加 Room 支持

更多 Emoji 列表：

- 官方参考： <https://github.com/ikatyang/emoji-cheat-sheet> (第三方整理)
- GitHub 自带渲染支持常见短代码

提示：在提交信息、Issue 标题或 PR 描述中适度使用 Emoji 可以提升可读性，但避免滥用以保持专业性。

如果你希望我把示例 README 中加入具体的 Emoji 标记（例如在功能完成项前加 ✅），我可以帮你自动插入。
