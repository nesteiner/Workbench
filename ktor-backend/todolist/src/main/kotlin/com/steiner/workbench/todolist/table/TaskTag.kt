package com.steiner.workbench.todolist.table

import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table

object TaskTag: Table("todolist-task-tag") {
    val taskid = reference("taskid", Tasks, onDelete = ReferenceOption.CASCADE)
    val tagid = reference("tagid", Tags, onDelete = ReferenceOption.CASCADE)
}