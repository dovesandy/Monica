package com.lingchongsen.sharedpreferences

import android.content.Context

/**
 * SharedPreferences 数据存储类
 * 该类封装了 SharedPreferences 的常用操作，提供了简洁的 API 接口
 * 用于数据的增删改查操作
 *
 * @param context 应用上下文，用于获取 SharedPreferences 实例
 */
class SharedPreferencesStore(private val context: Context) {
    // 获取名为 "app_prefs" 的 SharedPreferences 实例，使用私有模式
    private val prefs = context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE)

    /**
     * 保存字符串到 SharedPreferences
     * 该方法将指定的字符串值保存到 SharedPreferences 中
     *
     * @param key   数据的键
     * @param value 要保存的字符串值
     */
    fun saveString(key: String, value: String) {
        prefs.edit().putString(key, value).apply()
    }

    /**
     * 从 SharedPreferences 中读取字符串
     * 该方法根据键获取存储的字符串值
     *
     * @param key     数据的键
     * @param default 如果键不存在时的默认值，默认为空字符串
     * @return 存储的字符串值，或者默认值
     */
    fun getString(key: String, default: String = ""): String? {
        return prefs.getString(key, default)
    }

    /**
     * 删除指定键的数据
     * 该方法从 SharedPreferences 中删除指定键对应的值
     *
     * @param key 要删除的数据的键
     */
    fun remove(key: String) {
        prefs.edit().remove(key).apply()
    }

    /**
     * 清空所有数据
     * 该方法清空 SharedPreferences 中存储的所有数据
     */
    fun clear() {
        prefs.edit().clear().apply()
    }
}
