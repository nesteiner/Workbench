package com.steiner.workbench.todolist.model

import kotlinx.datetime.LocalDateTime
import kotlinx.serialization.Serializable

@Serializable
class TaskProject(
    val id: Int,
    val index: Int,
    val name: String,
    val avatarid: Int?,
    val userid: Int,
    val profile: String?,
    val createTime: LocalDateTime,
    val updateTime: LocalDateTime
)