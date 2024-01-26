package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.length
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`subtask-name-length`

@Serializable
class UpdateSubTaskRequest(
    val id: Int,
    val name: String?,
    val isdone: Boolean?,
) {
    fun validate() = length(name, max = `subtask-name-length`)
}