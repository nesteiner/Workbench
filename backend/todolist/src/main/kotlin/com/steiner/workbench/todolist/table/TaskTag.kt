package com.steiner.workbench.todolist.table

import org.jetbrains.exposed.sql.Table

object TaskTag: Table() {
    val taskid = reference("taskid", Tasks)
    val tagid = reference("tagid", Tags)
}