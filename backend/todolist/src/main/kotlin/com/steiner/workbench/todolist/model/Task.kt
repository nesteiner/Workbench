package com.steiner.workbench.todolist.model

import kotlinx.datetime.Instant

class Task(
        val id: Int,
        val index: Int,
        val name: String,
        val isdone: Boolean,

        // 0: low, 1: normal, 2: high
        val priority: Int,
        val note: String?,
        val subtasks: List<SubTask>?,
        val createTime: Instant,
        var updateTime: Instant,

        val expectTime: Int,
        val finishTime: Int,

        val deadline: Instant?,
        val notifyTime: Instant?,

        val tags: List<Tag>?,
        val parentid: Int
)