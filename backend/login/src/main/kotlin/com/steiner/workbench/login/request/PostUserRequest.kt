package com.steiner.workbench.login.request

import com.steiner.workbench.login.model.Role
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotEmpty
import jakarta.validation.constraints.NotNull
import org.hibernate.validator.constraints.Length

class PostUserRequest(
        @NotNull(message = "name cannot be null")
        @NotBlank(message = "name cannot be blank")
        @Length(min = 5, max = 24, message = "length of name must in 5-24")
        val name: String,

        @NotEmpty(message = "roles cannot be empty")
        val roles: List<Role>,

        @NotNull
        @NotBlank(message = "email cannot be blank")
        @Email
        val email: String,

        @NotNull(message = "enabled cannot be null")
        val enabled: Boolean,

        @NotNull(message = "password cannot be null")
        @NotBlank(message = "password cannot be empty")
        val passwordHash: String
)