package com.steiner.workbench.todolist.model

class SubTask(
        val id: Int,
        val index: Int,
        val name: String,
        val isdone: Boolean,
        val parentid: Int
)