package com.steiner.workbench.todolist.model

import kotlinx.datetime.Instant

class TaskGroup(
        val id: Int,
        val index: Int,
        val name: String,
        val tasks: List<Task>,
        val createTime: Instant,
        val updateTime: Instant,
        val parentid: Int
)