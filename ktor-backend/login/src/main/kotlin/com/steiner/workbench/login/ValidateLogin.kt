package com.steiner.workbench.login

import com.steiner.workbench.login.request.LoginRequest
import com.steiner.workbench.login.request.PostRoleRequest
import com.steiner.workbench.login.request.PostUserRequest
import com.steiner.workbench.login.request.UpdateUserRequest
import io.ktor.server.plugins.requestvalidation.*

val emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\$".toRegex()

fun RequestValidationConfig.validateLogin() {
    validate<PostUserRequest> {
        it.validate()
    }

    validate<LoginRequest> {
        it.validate()
    }

    validate<PostRoleRequest> {
        it.validate()
    }

    validate<UpdateUserRequest> {
        it.validate()
    }
}