package com.lingchongsen.datastore

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map

// 创建DataStore实例
private val Context.dataStore by preferencesDataStore(name = "user_data")

/**
 * DataStore管理类，用于处理增删改查操作
 */
class DataStoreManager(private val context: Context) {

    companion object {
        // 定义键
        private val USER_NAME_KEY = stringPreferencesKey("user_name")
        private val USER_AGE_KEY = stringPreferencesKey("user_age")
        private val USER_EMAIL_KEY = stringPreferencesKey("user_email")
    }

    /**
     * 【增】保存用户信息
     */
    suspend fun saveUserInfo(name: String, age: String, email: String) {
        try {
            context.dataStore.edit { preferences ->
                preferences[USER_NAME_KEY] = name
                preferences[USER_AGE_KEY] = age
                preferences[USER_EMAIL_KEY] = email
            }
        } catch (e: Exception) {
            throw Exception("保存数据失败: ${e.message}")
        }
    }

    /**
     * 【查】读取用户名
     */
    fun getUserName(): Flow<String> {
        return context.dataStore.data.map { preferences ->
            preferences[USER_NAME_KEY] ?: ""
        }
    }

    /**
     * 【查】读取用户年龄
     */
    fun getUserAge(): Flow<String> {
        return context.dataStore.data.map { preferences ->
            preferences[USER_AGE_KEY] ?: ""
        }
    }

    /**
     * 【查】读取用户邮箱
     */
    fun getUserEmail(): Flow<String> {
        return context.dataStore.data.map { preferences ->
            preferences[USER_EMAIL_KEY] ?: ""
        }
    }

    /**
     * 【查】一次性读取所有用户信息
     */
    suspend fun getAllUserInfo(): Triple<String, String, String> {
        return try {
            val preferences = context.dataStore.data.first()
            Triple(
                preferences[USER_NAME_KEY] ?: "",
                preferences[USER_AGE_KEY] ?: "",
                preferences[USER_EMAIL_KEY] ?: ""
            )
        } catch (e: Exception) {
            throw Exception("读取数据失败: ${e.message}")
        }
    }

    /**
     * 【改】修改用户名
     */
    suspend fun updateUserName(name: String) {
        try {
            context.dataStore.edit { preferences ->
                preferences[USER_NAME_KEY] = name
            }
        } catch (e: Exception) {
            throw Exception("修改用户名失败: ${e.message}")
        }
    }

    /**
     * 【改】修改用户年龄
     */
    suspend fun updateUserAge(age: String) {
        try {
            context.dataStore.edit { preferences ->
                preferences[USER_AGE_KEY] = age
            }
        } catch (e: Exception) {
            throw Exception("修改用户年龄失败: ${e.message}")
        }
    }

    /**
     * 【改】修改用户邮箱
     */
    suspend fun updateUserEmail(email: String) {
        try {
            context.dataStore.edit { preferences ->
                preferences[USER_EMAIL_KEY] = email
            }
        } catch (e: Exception) {
            throw Exception("修改用户邮箱失败: ${e.message}")
        }
    }

    /**
     * 【删】删除用户名
     */
    suspend fun deleteUserName() {
        try {
            context.dataStore.edit { preferences ->
                preferences.remove(USER_NAME_KEY)
            }
        } catch (e: Exception) {
            throw Exception("删除用户名失败: ${e.message}")
        }
    }

    /**
     * 【删】删除用户年龄
     */
    suspend fun deleteUserAge() {
        try {
            context.dataStore.edit { preferences ->
                preferences.remove(USER_AGE_KEY)
            }
        } catch (e: Exception) {
            throw Exception("删除用户年龄失败: ${e.message}")
        }
    }

    /**
     * 【删】删除用户邮箱
     */
    suspend fun deleteUserEmail() {
        try {
            context.dataStore.edit { preferences ->
                preferences.remove(USER_EMAIL_KEY)
            }
        } catch (e: Exception) {
            throw Exception("删除用户邮箱失败: ${e.message}")
        }
    }

    /**
     * 【删】清空所有数据
     */
    suspend fun clearAllData() {
        try {
            context.dataStore.edit { preferences ->
                preferences.clear()
            }
        } catch (e: Exception) {
            throw Exception("清空数据失败: ${e.message}")
        }
    }
}
