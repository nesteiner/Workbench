package com.steiner.workbench.login.request

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import org.hibernate.validator.constraints.Length

class UpdateRoleRequest(
        @NotNull(message = "id cannot be null")
        val id: Int,

        @NotBlank(message = "name cannot be blank")
        @Length(min = 5, max = 24, message = "length of name must in 5-24")
        val name: String
)