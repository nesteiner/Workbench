package com.steiner.workbench.login.request

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import org.hibernate.validator.constraints.Length

class LoginRequest(
        @NotNull(message = "username cannot be null")
        @NotBlank(message = "username cannot be blank")
        @Length(min = 5, max = 24, message = "length of username must in 5-24")
        val username: String,

        @NotNull(message = "passwordHash cannot be null")
        @NotBlank(message = "passwordHash cannot be blank")
        val passwordHash: String
)