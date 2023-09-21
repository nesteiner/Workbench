package com.steiner.workbench.todolist.request

import com.steiner.workbench.todolist.model.Tag
import com.steiner.workbench.todolist.validator.DateValid
import jakarta.validation.constraints.Min
import jakarta.validation.constraints.NotEmpty

class PostTaskRequest(
        @NotEmpty(message = "name cannot be empty")
        val name: String,

        val parentid: Int,

        val note: String?,
        val priority: Int,
        val tags: List<Tag>?,

        @DateValid(message = "deadline format error")
        val deadline: String?,

        @DateValid(message = "notify-time format error")
        val notifyTime: String?,

        @Min(1L, message = "expect time must greater than 0")
        val expectTime: Int
)