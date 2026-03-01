package com.lingchongsen.datastore

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.lingchongsen.datastore.ui.theme.DataStoreTheme
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            DataStoreTheme {
                DataStoreApp(context = this)
            }
        }
    }
}

@Composable
fun DataStoreApp(context: android.content.Context) {
    var nameInput by remember { mutableStateOf("") }
    var ageInput by remember { mutableStateOf("") }
    var emailInput by remember { mutableStateOf("") }
    
    var displayName by remember { mutableStateOf("") }
    var displayAge by remember { mutableStateOf("") }
    var displayEmail by remember { mutableStateOf("") }
    
    var message by remember { mutableStateOf("") }
    
    val dataStoreManager = DataStoreManager(context)
    val scope = rememberCoroutineScope()
    
    Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
        Column(
            modifier = Modifier
                .padding(innerPadding)
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.Top,
            horizontalAlignment = Alignment.Start
        ) {
            Text(
                text = "DataStore 增删改查教程",
                style = MaterialTheme.typography.headlineMedium,
                modifier = Modifier.padding(bottom = 16.dp)
            )
            
            Divider()
            
            // 输入框区域
            Text(
                text = "输入信息",
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.padding(vertical = 8.dp)
            )
            
            OutlinedTextField(
                value = nameInput,
                onValueChange = { nameInput = it },
                label = { Text("用户名") },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp)
            )
            
            OutlinedTextField(
                value = ageInput,
                onValueChange = { ageInput = it },
                label = { Text("年龄") },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp)
            )
            
            OutlinedTextField(
                value = emailInput,
                onValueChange = { emailInput = it },
                label = { Text("邮箱") },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp)
            )
            
            Divider(modifier = Modifier.padding(vertical = 16.dp))
            
            // 按钮区域
            Text(
                text = "操作按钮",
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.padding(vertical = 8.dp)
            )
            
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 8.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Button(
                    onClick = {
                        scope.launch {
                            try {
                                dataStoreManager.saveUserInfo(nameInput, ageInput, emailInput)
                                message = "✓ 数据保存成功！(增)"
                                displayName = nameInput
                                displayAge = ageInput
                                displayEmail = emailInput
                                nameInput = ""
                                ageInput = ""
                                emailInput = ""
                            } catch (e: Exception) {
                                message = "✗ 保存失败: ${e.message}"
                            }
                        }
                    },
                    modifier = Modifier
                        .weight(1f)
                        .padding(4.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.primary
                    )
                ) {
                    Text("保存【增】", modifier = Modifier.padding(4.dp))
                }
            }
            
            // 查询按钮
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 8.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Button(
                    onClick = {
                        scope.launch {
                            try {
                                val (name, age, email) = dataStoreManager.getAllUserInfo()
                                displayName = name
                                displayAge = age
                                displayEmail = email
                                message = "✓ 数据读取成功！(查)"
                            } catch (e: Exception) {
                                message = "✗ 读取失败: ${e.message}"
                            }
                        }
                    },
                    modifier = Modifier
                        .weight(1f)
                        .padding(4.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.secondary
                    )
                ) {
                    Text("查询【查】", modifier = Modifier.padding(4.dp))
                }
            }
            
            // 修改按钮
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 8.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Button(
                    onClick = {
                        scope.launch {
                            try {
                                if (nameInput.isNotEmpty()) {
                                    dataStoreManager.updateUserName(nameInput)
                                    displayName = nameInput
                                    message = "✓ 用户名修改成功！(改)"
                                    nameInput = ""
                                } else {
                                    message = "✗ 请输入用户名"
                                }
                            } catch (e: Exception) {
                                message = "✗ 修改失败: ${e.message}"
                            }
                        }
                    },
                    modifier = Modifier
                        .weight(1f)
                        .padding(4.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.tertiary
                    )
                ) {
                    Text("修改【改】", modifier = Modifier.padding(4.dp))
                }
            }
            
            // 删除按钮
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 8.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Button(
                    onClick = {
                        scope.launch {
                            try {
                                dataStoreManager.deleteUserName()
                                displayName = ""
                                message = "✓ 用户名删除成功！(删)"
                            } catch (e: Exception) {
                                message = "✗ 删除失败: ${e.message}"
                            }
                        }
                    },
                    modifier = Modifier
                        .weight(1f)
                        .padding(4.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.error
                    )
                ) {
                    Text("删除【删】", modifier = Modifier.padding(4.dp))
                }
                
                Button(
                    onClick = {
                        scope.launch {
                            try {
                                dataStoreManager.clearAllData()
                                displayName = ""
                                displayAge = ""
                                displayEmail = ""
                                message = "✓ 所有数据已清空！"
                            } catch (e: Exception) {
                                message = "✗ 清空失败: ${e.message}"
                            }
                        }
                    },
                    modifier = Modifier
                        .weight(1f)
                        .padding(4.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.error
                    )
                ) {
                    Text("清空所有", modifier = Modifier.padding(4.dp))
                }
            }
            
            Divider(modifier = Modifier.padding(vertical = 16.dp))
            
            // 显示数据区域
            Text(
                text = "当前存储的数据",
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.padding(vertical = 8.dp)
            )
            
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(8.dp)
            ) {
                Column(
                    modifier = Modifier.padding(12.dp)
                ) {
                    Text(
                        text = "用户名: $displayName",
                        style = MaterialTheme.typography.bodyMedium
                    )
                    Text(
                        text = "年龄: $displayAge",
                        style = MaterialTheme.typography.bodyMedium
                    )
                    Text(
                        text = "邮箱: $displayEmail",
                        style = MaterialTheme.typography.bodyMedium
                    )
                }
            }
            
            Spacer(modifier = Modifier.weight(1f))
            
            // 提示信息区域（底部）
            if (message.isNotEmpty()) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(8.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = if (message.contains("✓"))
                            MaterialTheme.colorScheme.primaryContainer
                        else
                            MaterialTheme.colorScheme.errorContainer
                    )
                ) {
                    Text(
                        text = message,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(12.dp),
                        style = MaterialTheme.typography.bodyMedium,
                        color = if (message.contains("✓"))
                            MaterialTheme.colorScheme.onPrimaryContainer
                        else
                            MaterialTheme.colorScheme.onErrorContainer
                    )
                }
            }
        }
    }
}