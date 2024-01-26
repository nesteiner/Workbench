package com.steiner.workbench.todolist.model

import kotlinx.datetime.LocalDateTime
import kotlinx.serialization.Serializable

@Serializable
class TaskGroup(
    val id: Int,
    val index: Int,
    val name: String,
    val tasks: List<Task>,
    val createTime: LocalDateTime,
    val updateTime: LocalDateTime,
    val parentid: Int
)