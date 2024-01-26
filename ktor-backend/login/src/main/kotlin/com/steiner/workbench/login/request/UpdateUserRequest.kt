package com.steiner.workbench.login.request

import com.steiner.workbench.common.`common-string-length-min`
import com.steiner.workbench.common.`user-request-email-length-max`
import com.steiner.workbench.common.`user-request-password-length-max`
import com.steiner.workbench.common.`user-request-username-length-max`
import com.steiner.workbench.common.util.between
import com.steiner.workbench.common.util.length
import com.steiner.workbench.common.util.email as vEmail
import io.ktor.server.plugins.requestvalidation.*
import kotlinx.serialization.Serializable

@Serializable
class UpdateUserRequest(
    val id: Int,
    val username: String?,
    val email: String?,
    val enabled: Boolean?,
    val passwordHash: String?,
    val passwordLength: Int?
) {
    fun validate(): ValidationResult {
        return listOf(
            length(data = username, min = `common-string-length-min`, max = `user-request-username-length-max`),
            length(data = email, max = `user-request-email-length-max`),
            between(data = passwordLength, min = `common-string-length-min`, max = `user-request-password-length-max`),
            vEmail(data = email)
        ).firstOrNull {
            it is ValidationResult.Invalid
        } ?: ValidationResult.Valid
    }
}