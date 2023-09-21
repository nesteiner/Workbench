package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.TAG_NAME_LENGTH
import jakarta.validation.constraints.NotEmpty
import org.hibernate.validator.constraints.Length

class UpdateTagRequest(
        val id: Int,

        @NotEmpty(message = "tag name cannot be empty")
        @Length(max = TAG_NAME_LENGTH, message = "length of tag name must less than $TAG_NAME_LENGTH")
        val name: String
)
