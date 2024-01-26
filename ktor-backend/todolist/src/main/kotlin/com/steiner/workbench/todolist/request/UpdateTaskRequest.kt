package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.length
import com.steiner.workbench.todolist.model.Priority
import kotlinx.datetime.LocalDateTime
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`task-name-length`

@Serializable
class UpdateTaskRequest(
    val id: Int,
    val name: String?,
    val isdone: Boolean?,
    val deadline: LocalDateTime?,
    val notifyTime: LocalDateTime?,
    val note: String?,
    val priority: Priority?,
    val expectTime: Int?,
    val finishTime: Int?,
    val parentid: Int?
) {
    fun validate() = length(data = name, max = `task-name-length`)
}