package com.steiner.workbench.todolist.model

import kotlinx.serialization.Serializable

@Serializable
class Tag(
    val id: Int,
    val name: String,
    val parentid: Int,
    val color: String
)