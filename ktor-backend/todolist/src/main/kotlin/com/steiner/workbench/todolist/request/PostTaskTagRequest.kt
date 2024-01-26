package com.steiner.workbench.todolist.request

import kotlinx.serialization.Serializable

@Serializable
class PostTaskTagRequest(
    val taskid: Int,
    val tagid: Int
)