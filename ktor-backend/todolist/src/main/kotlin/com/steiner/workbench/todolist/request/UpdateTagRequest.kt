package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.length
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`tag-name-length`

@Serializable
class UpdateTagRequest(
    val id: Int,
    val name: String
) {
    fun validate() = length(data = name, max = `tag-name-length`)
}