package com.steiner.workbench.login.request

import com.steiner.workbench.common.util.length
import io.ktor.server.plugins.requestvalidation.*
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`user-name-length`

@Serializable
class LoginRequest(
    val username: String,
    val passwordHash: String
) {
    fun validate(): ValidationResult {
        return listOf(
            length(data = username, max = `user-name-length`)
        ).firstOrNull {
            it is ValidationResult.Invalid
        } ?: ValidationResult.Valid
    }
}