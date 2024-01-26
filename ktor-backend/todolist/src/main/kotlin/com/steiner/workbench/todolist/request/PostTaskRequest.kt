package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.length
import com.steiner.workbench.todolist.model.Priority
import com.steiner.workbench.todolist.model.Tag
import io.ktor.server.plugins.requestvalidation.*
import kotlinx.datetime.LocalDateTime
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`task-name-length`

@Serializable
class PostTaskRequest(
    val name: String,
    val parentid: Int,
    val note: String?,
    val priority: Priority,
    val tags: List<Tag>?,
    val deadline: LocalDateTime?,
    val notifyTime: LocalDateTime?,
    val expectTime: Int
) {
    fun validate(): ValidationResult = length(data = name, max = `task-name-length`)
}