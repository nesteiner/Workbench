package com.steiner.workbench.todolist.table

import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table

object TaskPriority: Table("todolist-task-priority") {
    val taskid = reference("taskid", Tasks, onDelete = ReferenceOption.CASCADE)
    val priorityid = reference("priorityid", Priorities, onDelete = ReferenceOption.CASCADE)
}