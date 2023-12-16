package com.steiner.workbench.clipboard.request

import com.steiner.workbench.common.CLIPBOARD_TEXT_LENGTH
import jakarta.validation.constraints.NotEmpty
import org.hibernate.validator.constraints.Length

class PostTextRequest(
    @NotEmpty(message = "text cannot be empty")
    @Length(max = CLIPBOARD_TEXT_LENGTH, message = "text length overflow")
    val text: String,

    val userid: Int
)