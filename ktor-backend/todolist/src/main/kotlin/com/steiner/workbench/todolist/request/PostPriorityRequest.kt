package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.length
import com.steiner.workbench.common.util.min
import io.ktor.server.plugins.requestvalidation.*
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`priority-name-length`

@Serializable
class PostPriorityRequest(
    val name: String,
    val order: Int,
    val parentid: Int
) {
    fun validate(): ValidationResult {
        return listOf(
            length(data = name, max = `priority-name-length`),
            min(data = order, value = 0),
        ).firstOrNull {
            it is ValidationResult.Invalid
        } ?: ValidationResult.Valid
    }
}