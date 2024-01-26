package com.steiner.workbench.todolist.model

import kotlinx.serialization.Serializable

@Serializable
class Priority(
    val id: Int,
    val name: String,
    val order: Int,
    val parentid: Int
)