package com.steiner.workbench.todolist.model

import kotlinx.datetime.LocalDateTime
import kotlinx.serialization.Serializable

@Serializable
class Task(
    val id: Int,
    val index: Int,
    val name: String,
    val isdone: Boolean,
    val priority: Priority,
    val note: String?,
    val subtasks: List<SubTask>,
    val expectTime: Int,
    val finishTime: Int,
    val deadline: LocalDateTime?,
    val notifyTime: LocalDateTime?,
    val tags: List<Tag>,
    val parentid: Int,
    val createTime: LocalDateTime,
    val updateTime: LocalDateTime
)