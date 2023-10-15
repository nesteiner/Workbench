package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.TASK_GROUP_NAME_LENGTH
import jakarta.validation.constraints.NotEmpty
import org.hibernate.validator.constraints.Length

class UpdateTaskGroupRequest(
        val id: Int,
        @Length(max = TASK_GROUP_NAME_LENGTH, message = "length of task group name must less than $TASK_GROUP_NAME_LENGTH")
        val name: String?,
        val reorderAt: Int?
)