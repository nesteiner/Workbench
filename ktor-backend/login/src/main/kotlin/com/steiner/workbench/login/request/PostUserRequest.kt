package com.steiner.workbench.login.request

import com.steiner.workbench.common.`common-string-length-min`
import com.steiner.workbench.common.`user-request-email-length-max`
import com.steiner.workbench.common.`user-request-username-length-max`
import com.steiner.workbench.common.util.length
import com.steiner.workbench.common.util.email as vEmail
import com.steiner.workbench.common.util.min
import io.ktor.server.plugins.requestvalidation.*
import kotlinx.serialization.Serializable

@Serializable
class PostUserRequest(
    val username: String,
    val passwordHash: String,
    val email: String,
    val passwordLength: Int,
    val enabled: Boolean
) {
    fun validate(): ValidationResult {
        return listOf(
            length(data = username, min = `common-string-length-min`, max = `user-request-username-length-max`),
            min(data = passwordLength, value = `common-string-length-min`),
            length(data = email, max = `user-request-email-length-max`),
            vEmail(data = email)
        ).firstOrNull {
            it is ValidationResult.Invalid
        } ?: ValidationResult.Valid
    }
}