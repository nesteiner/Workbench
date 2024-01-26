package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.length
import io.ktor.server.plugins.requestvalidation.*
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`task-group-name-length`

@Serializable
class PostTaskGroupRequest(
    val parentid: Int,
    val name: String
) {
    fun validate(): ValidationResult {
        return length(data = name, max = `task-group-name-length`)
    }
}