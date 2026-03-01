# DataStore 增删改查教程

这是一个简单的 DataStore 使用教程项目，展示了如何在 Android 应用中使用 DataStore 进行数据持久化操作。

## 项目结构

```
app/src/main/java/com/lingchongsen/datastore/
├── MainActivity.kt                 # 主Activity，包含UI和业务逻辑
├── DataStoreManager.kt            # DataStore管理类，封装了增删改查方法
└── ui/theme/                       # UI主题文件
```

## 功能说明

### 1. DataStoreManager.kt （DataStore管理类）

这个文件包含了所有的 DataStore 操作方法：

#### 【增】保存数据

```kotlin
suspend fun saveUserInfo(name: String, age: String, email: String)
```

保存用户的完整信息（用户名、年龄、邮箱）

#### 【查】读取数据

```kotlin
fun getUserName(): Flow<String>       // 读取用户名
fun getUserAge(): Flow<String>        // 读取年龄
fun getUserEmail(): Flow<String>      // 读取邮箱
suspend fun getAllUserInfo(): Triple<String, String, String>  // 一次性读取所有信息
```

#### 【改】修改数据

```kotlin
suspend fun updateUserName(name: String)    // 修改用户名
suspend fun updateUserAge(age: String)      // 修改年龄
suspend fun updateUserEmail(email: String)  // 修改邮箱
```

#### 【删】删除数据

```kotlin
suspend fun deleteUserName()    // 删除用户名
suspend fun deleteUserAge()     // 删除年龄
suspend fun deleteUserEmail()   // 删除邮箱
suspend fun clearAllData()      // 清空所有数据
```

### 2. MainActivity.kt （UI界面和交互逻辑）

包含以下主要部分：

#### 输入框部分

- **用户名输入框** - 输入要保存或修改的用户名
- **年龄输入框** - 输入用户年龄
- **邮箱输入框** - 输入用户邮箱

#### 按钮部分

- **保存【增】** - 保存输入框中的所有信息到 DataStore
- **查询【查】** - 从 DataStore 读取所有保存的数据并显示
- **修改【改】** - 修改用户名（年龄和邮箱也可类似修改）
- **删除【删】** - 删除用户名
- **清空所有** - 清空 DataStore 中的所有数据

#### 显示区域

- **当前存储的数据** - 显示 DataStore 中当前保存的数据

#### 提示信息区域（底部）

- 操作成功时显示绿色提示信息
- 操作失败时显示红色错误信息
- 包含对应的操作标记（增、删、改、查）

## 使用步骤

### 1. 保存数据（增）

```
1. 在输入框中分别输入用户名、年龄、邮箱
2. 点击"保存【增】"按钮
3. 屏幕底部会显示"✓ 数据保存成功！(增)"
```

### 2. 查询数据（查）

```
1. 点击"查询【查】"按钮
2. 屏幕底部会显示"✓ 数据读取成功！(查)"
3. 当前存储的数据区域会显示读取的数据
```

### 3. 修改数据（改）

```
1. 在用户名输入框中输入新的用户名
2. 点击"修改【改】"按钮
3. 屏幕底部会显示"✓ 用户名修改成功！(改)"
4. 当前存储的数据区域会更新显示
```

### 4. 删除数据（删）

```
方式1 - 删除单个字段：
1. 点击"删除【删】"按钮删除用户名
2. 屏幕底部会显示"✓ 用户名删除成功！(删)"

方式2 - 清空所有数据：
1. 点击"清空所有"按钮
2. 屏幕底部会显示"✓ 所有数据已清空！"
3. 当前存储的数据区域会清空
```

## 核心知识点

### DataStore 基础概念

- **DataStore** 是 Android 推荐的数据存储方案，替代 SharedPreferences
- 使用 **Key-Value** 形式存储数据
- 提供了一个 **流（Flow）** 接口来观察数据变化
- 所有操作都是 **异步** 的，需要在协程中执行

### 关键代码片段

#### 1. 定义 Key

```kotlin
private val USER_NAME_KEY = stringPreferencesKey("user_name")
private val USER_AGE_KEY = stringPreferencesKey("user_age")
private val USER_EMAIL_KEY = stringPreferencesKey("user_email")
```

#### 2. 保存数据（写）

```kotlin
suspend fun saveUserInfo(name: String, age: String, email: String) {
    context.dataStore.edit { preferences ->
        preferences[USER_NAME_KEY] = name
        preferences[USER_AGE_KEY] = age
        preferences[USER_EMAIL_KEY] = email
    }
}
```

#### 3. 读取数据（读）

```kotlin
fun getUserName(): Flow<String> {
    return context.dataStore.data.map { preferences ->
        preferences[USER_NAME_KEY] ?: ""
    }
}
```

#### 4. 并发处理

```kotlin
val scope = rememberCoroutineScope()
scope.launch {
    try {
        dataStoreManager.saveUserInfo(nameInput, ageInput, emailInput)
        message = "✓ 数据保存成功！(增)"
    } catch (e: Exception) {
        message = "✗ 保存失败: ${e.message}"
    }
}
```

## 依赖项

项目使用了以下主要依赖：

- `androidx.datastore:datastore-preferences` - DataStore 库
- `org.jetbrains.kotlinx:kotlinx-coroutines-android` - 协程库
- `androidx.compose.*` - Jetpack Compose UI 框架

## 学习路径建议

1. **初级** - 理解增删改查的基本概念
2. **中级** - 学习异步操作和协程的使用
3. **高级** - 扩展功能，如使用 ViewModel、LiveData 等

## 常见问题

**Q: 为什么要使用 DataStore 而不是 SharedPreferences？**
A: DataStore 提供了以下优势：

- 异步操作，不会阻塞 UI 线程
- 类型安全的键
- 更好的错误处理
- 支持事务性操作

**Q: 数据存储在哪里？**
A: DataStore 数据被存储在应用的私有目录中的 protocol buffer 文件中。
路径通常是：`/data/data/com.lingchongsen.datastore/files/datastore/user_data.preferences_pb`

**Q: 可以存储复杂对象吗？**
A: DataStore Preferences 只支持基本类型（String、Int、Boolean 等）。如果需要存储复杂对象，建议使用 DataStore with Protocol Buffers。

## 扩展建议

- [ ] 添加更多数据字段
- [ ] 实现 ViewModel 来管理 UI 状态
- [ ] 添加数据验证功能
- [ ] 实现数据导出/导入功能
- [ ] 添加数据加密存储

---

**作者说明**：这是一个教学示例项目，目的是帮助开发者快速理解 DataStore 的基本使用方法。
