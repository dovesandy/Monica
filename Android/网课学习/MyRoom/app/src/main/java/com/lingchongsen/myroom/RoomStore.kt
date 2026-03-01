package com.lingchongsen.myroom

import android.content.Context
import com.lingchongsen.myroom.db.AppDatabase
import com.lingchongsen.myroom.model.User
import kotlinx.coroutines.flow.Flow

/**
 * RoomStore 封装常用的增删改查方法
 */
class RoomStore(context: Context) {
    private val db = AppDatabase.getInstance(context)
    private val userDao = db.userDao()

    // 查询所有用户
    fun getAllUsers(): Flow<List<User>> = userDao.getAll()

    // 插入用户，返回插入id
    suspend fun insertUser(name: String, age: Int, email: String): Long {
        val user = User(name = name, age = age, email = email)
        return userDao.insert(user)
    }

    // 更新用户（需要带 id）
    suspend fun updateUser(user: User) {
        userDao.update(user)
    }

    // 删除用户
    suspend fun deleteUser(user: User) {
        userDao.delete(user)
    }

    // 清空所有
    suspend fun clearAll() {
        userDao.clearAll()
    }
}
