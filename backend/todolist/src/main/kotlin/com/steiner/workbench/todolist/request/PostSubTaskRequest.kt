package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.SUBTASK_NAME_LENGTH
import jakarta.validation.constraints.Max
import jakarta.validation.constraints.NotEmpty

class PostSubTaskRequest(
        val parentid: Int,
        @NotEmpty(message = "subtask name cannot be empty")
        @Max(SUBTASK_NAME_LENGTH.toLong(), message = "subtask name length must greater than $SUBTASK_NAME_LENGTH")
        val name: String
)
