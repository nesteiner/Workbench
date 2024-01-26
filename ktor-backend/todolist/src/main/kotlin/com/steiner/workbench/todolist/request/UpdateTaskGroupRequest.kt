package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.length
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`task-group-name-length`

@Serializable
class UpdateTaskGroupRequest(
    val id: Int,
    val name: String
) {
    fun validate() = length(data = name, max = `task-group-name-length`)
}