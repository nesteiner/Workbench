package com.steiner.workbench.login.request

import com.steiner.workbench.login.model.Role
import jakarta.validation.constraints.Email
import org.hibernate.validator.constraints.Length

class UpdateUserRequest(
        @Length(min = 5, max = 24, message = "length of name must in 5-24")
        val name: String?,

        val roles: List<Role>?,

        @Email
        val email: String?,

        val enabled: Boolean?
)