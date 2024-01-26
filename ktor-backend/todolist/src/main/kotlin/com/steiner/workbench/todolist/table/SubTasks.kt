package com.steiner.workbench.todolist.table

import com.steiner.workbench.common.`subtask-name-length`
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption

object SubTasks: IntIdTable("todolist-subtasks") {
    val index = integer("index")
    val name = varchar("name", `subtask-name-length`)
    val isdone = bool("isdone")
    val parentid = reference("parentid", Tasks, onDelete = ReferenceOption.CASCADE)
}