package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.TASK_PROJECT_NAME_LENGTH
import jakarta.validation.constraints.NotEmpty
import org.hibernate.validator.constraints.Length

class PostTaskProjectRequest(
        val userid: Int,

        @NotEmpty(message = "task project name cannot be empty")
        @Length(max = TASK_PROJECT_NAME_LENGTH, message = "length of task project name must less than $TASK_PROJECT_NAME_LENGTH")
        val name: String,

        val avatarid: Int?
)