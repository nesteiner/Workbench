package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.SUBTASK_NAME_LENGTH
import org.hibernate.validator.constraints.Length

class UpdateSubTaskRequest(
        val id: Int,

        @Length(max = SUBTASK_NAME_LENGTH, message = "length of subtask name must less than $SUBTASK_NAME_LENGTH")
        val name: String?,

        val isdone: Boolean?
)