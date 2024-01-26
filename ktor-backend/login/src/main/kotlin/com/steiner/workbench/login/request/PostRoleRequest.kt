package com.steiner.workbench.login.request

import com.steiner.workbench.common.util.length
import io.ktor.server.plugins.requestvalidation.*
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`role-name-length`

@Serializable
class PostRoleRequest(
    val name: String
) {
    fun validate(): ValidationResult {
        return length(data = name, max = `role-name-length`)
    }
}