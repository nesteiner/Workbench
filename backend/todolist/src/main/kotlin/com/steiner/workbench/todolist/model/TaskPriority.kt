package com.steiner.workbench.todolist.model

enum class TaskPriority(val value: Int) {
    LOW(0),
    NORMAL(1),
    HIGH(2),
    UNKNOWN(-1)
}