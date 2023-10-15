package com.steiner.workbench.todolist.model

import kotlinx.datetime.Instant

class TaskProject(
        val id: Int,
        val index: Int,
        val name: String,
        val avatarid: Int,
        val userid: Int,
        val profile: String?,
        val createTime: Instant,
        val updateTime: Instant
)