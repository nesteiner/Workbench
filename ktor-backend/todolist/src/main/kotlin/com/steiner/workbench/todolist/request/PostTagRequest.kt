package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.length
import com.steiner.workbench.common.util.color as vColor
import io.ktor.server.plugins.requestvalidation.*
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`role-name-length`

@Serializable
class PostTagRequest(
    val name: String,
    val parentid: Int,
    val color: String
) {
    fun validate(): ValidationResult {
        return listOf(
            length(data = name, max = `role-name-length`),
            vColor(data = this.color)
        ).firstOrNull {
            it is ValidationResult.Invalid
        } ?: ValidationResult.Valid
    }
}