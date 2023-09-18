package com.steiner.workbench.login.request

import jakarta.validation.constraints.NotBlank

class PostRoleRequest(
        @NotBlank(message = "role name cannot be blank")
        val name: String
)