package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.length
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`task-project-name-length`

@Serializable
class UpdateTaskProjectRequest(
    val id: Int,
    val name: String?,
    val avatarid: Int?,
    val profile: String?
) {
    fun validate() = length(data = name, max = `task-project-name-length`)
}