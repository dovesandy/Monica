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

@Composable
fun SharedPrefScreen(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val input = rememberSaveable { mutableStateOf("") }
    val store = remember { SharedPreferencesStore(context) }

    Column(
        modifier = modifier.fillMaxSize().padding(16.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        OutlinedTextField(
            value = input.value,
            onValueChange = { input.value = it },
            label = { Text("请输入文本") },
            modifier = Modifier
                .size(width = 320.dp, height = 56.dp)
        )

        Button(
            onClick = {
                store.saveString("saved_text", input.value)
                Toast.makeText(context, "数据已经保存成功", Toast.LENGTH_SHORT).show()
            },
            modifier = Modifier.padding(top = 12.dp)
        ) {
            Text("保存")
        }

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

@Preview(showBackground = true)
@Composable
fun SharedPrefPreview() {
    SharedPreferencesTheme {
        SharedPrefScreen()
    }
}