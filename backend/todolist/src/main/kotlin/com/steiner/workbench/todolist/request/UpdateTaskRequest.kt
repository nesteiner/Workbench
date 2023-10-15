package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.TASK_NAME_LENGTH
import com.steiner.workbench.todolist.validator.DateValid
import jakarta.validation.constraints.Min
import org.hibernate.validator.constraints.Length

class UpdateTaskRequest(
        val id: Int,
        val reorderAt: Int?,
        @Length(max = TASK_NAME_LENGTH, message = "length of task name must less than $TASK_NAME_LENGTH")
        val name: String?,
        val isdone: Boolean?,

        @DateValid(format = "yyyy-MM-dd HH:mm", message = "deadline format error")
        val deadline: String?,

        @DateValid(format = "yyyy-MM-dd HH:mm", message = "notify time format error")
        val notifyTime: String?,
        val note: String?,
        val priority: Int?,

        @Min(1, message = "expect time must greater than 0")
        val expectTime: Int?,

        @Min(0, message = "finish time must greater than or equal 0")
        val finishTime: Int?,

        val parentid: Int?
)