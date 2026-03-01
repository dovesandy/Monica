package com.lingchongsen.myroom

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.tooling.preview.Preview
import com.lingchongsen.myroom.model.User
import com.lingchongsen.myroom.ui.theme.MyRoomTheme
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyRoomTheme {
                RoomApp(context = this)
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RoomApp(context: android.content.Context) {
    val store = remember { RoomStore(context) }
    val scope = rememberCoroutineScope()

    var name by remember { mutableStateOf("") }
    var age by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }

    var message by remember { mutableStateOf("") }
    var selectedUser by remember { mutableStateOf<User?>(null) }

    val users by store.getAllUsers().collectAsState(initial = emptyList())

    Scaffold(modifier = Modifier.fillMaxSize()) { inner ->
        Column(
            modifier = Modifier
                .padding(inner)
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(16.dp)
        ) {
            Text(text = "Room 增删改查示例", style = MaterialTheme.typography.headlineSmall)
            Spacer(modifier = Modifier.height(12.dp))

            OutlinedTextField(
                value = name,
                onValueChange = { name = it },
                label = { Text("用户名") },
                modifier = Modifier.fillMaxWidth()
            )
            Spacer(modifier = Modifier.height(8.dp))
            OutlinedTextField(
                value = age,
                onValueChange = { age = it.filter { ch -> ch.isDigit() } },
                label = { Text("年龄") },
                modifier = Modifier.fillMaxWidth()
            )
            Spacer(modifier = Modifier.height(8.dp))
            OutlinedTextField(
                value = email,
                onValueChange = { email = it },
                label = { Text("邮箱") },
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(12.dp))

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Button(onClick = {
                    scope.launch {
                        try {
                            val insertedId = store.insertUser(name.trim(), age.toIntOrNull() ?: 0, email.trim())
                            message = "✓ 插入成功 id=$insertedId"
                            name = ""; age = ""; email = ""
                        } catch (e: Exception) {
                            message = "✗ 插入失败: ${e.message}"
                        }
                    }
                }) { Text("插入【增】") }

                Button(onClick = {
                    // 若已选择则更新，否则提示
                    scope.launch {
                        try {
                            val user = selectedUser
                            if (user != null) {
                                val updated = user.copy(name = name.ifEmpty { user.name }, age = age.toIntOrNull() ?: user.age, email = email.ifEmpty { user.email })
                                store.updateUser(updated)
                                message = "✓ 更新成功"
                                selectedUser = null
                                name = ""; age = ""; email = ""
                            } else {
                                message = "✗ 请先在列表中选择要更新的用户"
                            }
                        } catch (e: Exception) {
                            message = "✗ 更新失败: ${e.message}"
                        }
                    }
                }) { Text("更新【改】") }

                Button(onClick = {
                    scope.launch {
                        try {
                            val user = selectedUser
                            if (user != null) {
                                store.deleteUser(user)
                                message = "✓ 删除成功"
                                selectedUser = null
                                name = ""; age = ""; email = ""
                            } else {
                                message = "✗ 请先在列表中选择要删除的用户"
                            }
                        } catch (e: Exception) {
                            message = "✗ 删除失败: ${e.message}"
                        }
                    }
                }) { Text("删除【删】") }

                Button(onClick = {
                    scope.launch {
                        try {
                            store.clearAll()
                            message = "✓ 所有数据已清空"
                            selectedUser = null
                            name = ""; age = ""; email = ""
                        } catch (e: Exception) {
                            message = "✗ 清空失败: ${e.message}"
                        }
                    }
                }) { Text("清空所有") }
            }

            Spacer(modifier = Modifier.height(16.dp))

            Text(text = "用户列表（点击选择）", style = MaterialTheme.typography.titleMedium)
            Spacer(modifier = Modifier.height(8.dp))

            Card(modifier = Modifier.fillMaxWidth()) {
                if (users.isEmpty()) {
                    Text("暂无用户", modifier = Modifier.padding(12.dp))
                } else {
                    LazyColumn(modifier = Modifier.fillMaxWidth()) {
                        items(users) { user ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clickable {
                                        selectedUser = user
                                        name = user.name
                                        age = user.age.toString()
                                        email = user.email
                                        message = "已选择 id=${user.id}"
                                    }
                                    .padding(12.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(text = "${user.name} (id=${user.id})")
                                    Text(text = "年龄: ${user.age}  邮箱: ${user.email}")
                                }
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            if (message.isNotEmpty()) {
                Card(modifier = Modifier.fillMaxWidth()) {
                    Text(text = message, modifier = Modifier.padding(12.dp))
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun RoomPreview() {
    MyRoomTheme {
        // preview with empty context isn't interactive
        Column(modifier = Modifier.padding(16.dp)) {
            Text("Room 示例预览")
        }
    }
}