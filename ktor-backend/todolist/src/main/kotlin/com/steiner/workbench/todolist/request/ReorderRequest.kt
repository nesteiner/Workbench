package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.min
import io.ktor.server.plugins.requestvalidation.*
import kotlinx.serialization.Serializable

@Serializable
class ReorderRequest(
    val currentIndex: Int,
    val reorderAfter: Int
) {
    fun validate(): ValidationResult {
        return listOf(
            min(data = currentIndex, value = 0),
            min(data = reorderAfter, value = 0)
        ).firstOrNull {
            it is ValidationResult.Invalid
        } ?: ValidationResult.Valid
    }
}