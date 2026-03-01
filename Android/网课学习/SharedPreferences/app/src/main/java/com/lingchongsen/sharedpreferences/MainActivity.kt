package com.lingchongsen.sharedpreferences

import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Button
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lingchongsen.sharedpreferences.ui.theme.SharedPreferencesTheme

/**
 * SharedPreferences 教程示例 - 主活动
 * 该活动展示了如何使用 Compose 和 SharedPreferences 进行数据的保存和读取
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            SharedPreferencesTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    SharedPrefScreen(modifier = Modifier.padding(innerPadding))
                }
            }
        }
    }
}

/**
 * SharedPreferences 交互界面
 * 提供输入框和保存/获取按钮供用户交互
 *
 * @param modifier 用于调整 UI 布局的修饰符
 */
@Composable
fun SharedPrefScreen(modifier: Modifier = Modifier) {
    // 获取当前上下文
    val context = LocalContext.current
    // 保存用户输入的文本状态，enable 重启后保持输入内容
    val input = rememberSaveable { mutableStateOf("") }
    // 初始化 SharedPreferences 存储类实例
    val store = remember { SharedPreferencesStore(context) }

    // 使用 Column 布局，垂直排列 UI 元素
    Column(
        modifier = modifier.fillMaxSize().padding(16.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // 输入框 - 用户输入要保存的文本
        OutlinedTextField(
            value = input.value,
            onValueChange = { input.value = it },
            label = { Text("请输入文本") },
            modifier = Modifier
                .size(width = 320.dp, height = 56.dp)
        )

        // 保存按钮 - 点击后将输入框内容保存到 SharedPreferences
        Button(
            onClick = {
                store.saveString("saved_text", input.value)
                Toast.makeText(context, "数据已经保存成功", Toast.LENGTH_SHORT).show()
            },
            modifier = Modifier.padding(top = 12.dp)
        ) {
            Text("保存")
        }

        // 获取按钮 - 点击后从 SharedPreferences 读取保存的数据并显示
        Button(
            onClick = {
                val saved = store.getString("saved_text", "") ?: ""
                Toast.makeText(context, "获取的数据: $saved", Toast.LENGTH_SHORT).show()
            },
            modifier = Modifier.padding(top = 8.dp)
        ) {
            Text("获取")
        }
    }
}

/**
 * Preview - 用于在 Android Studio 中预览 UI 效果
 */
@Preview(showBackground = true)
@Composable
fun SharedPrefPreview() {
    SharedPreferencesTheme {
        SharedPrefScreen()
    }
}