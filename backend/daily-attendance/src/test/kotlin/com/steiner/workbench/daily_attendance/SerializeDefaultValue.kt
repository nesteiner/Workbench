package com.steiner.workbench.daily_attendance

import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Test

class SerializeDefaultValue {
    @Serializable
    class Item(val id: Int = 0)
    @Test
    fun `test serialize with default value`() {
        val s = Json.encodeToString(Item())
        println(s)
    }
}