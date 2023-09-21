package com.steiner.workbench.todolist.model

import java.sql.Timestamp

class Task(
        val id: Int,
        var name: String,
        var isdone: Boolean,
        var priority: TaskPriority,
        var note: String?,
        var subtasks: List<SubTask>?,
        val createTime: Timestamp,
        var updateTime: Timestamp,

        var expectTime: Int,
        var finishTime: Int,

        var deadline: Timestamp?,
        var notifyTime: Timestamp?,

        var tags: List<Tag>?,

)