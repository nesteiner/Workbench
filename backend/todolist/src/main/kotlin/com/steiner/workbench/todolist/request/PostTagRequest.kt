package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.TAG_NAME_LENGTH
import jakarta.validation.constraints.NotEmpty
import org.hibernate.validator.constraints.Length

class PostTagRequest(
        @NotEmpty(message = "name cannot be empty")
        @Length(max = TAG_NAME_LENGTH, message = "length of name must less than $TAG_NAME_LENGTH")
        val name: String,

        val parentid: Int
)