package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.TASK_PROJECT_NAME_LENGTH
import org.hibernate.validator.constraints.Length

class UpdateTaskProjectRequest(
        val id: Int,
        @Length(max = TASK_PROJECT_NAME_LENGTH, message = "length of task project name must less than $TASK_PROJECT_NAME_LENGTH")
        val name: String?,
        val avatarid: Int?,
        val profile: String?
)