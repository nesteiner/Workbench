package com.steiner.workbench.todolist.table

import com.steiner.workbench.common.SUBTASK_NAME_LENGTH
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption

object SubTasks: IntIdTable("todolist-subtasks") {
    val index = integer("index")
    val name = varchar("name", SUBTASK_NAME_LENGTH)
    val isdone = bool("isdone")
    // parentid
    val parentid = reference("parentid", Tasks, onDelete = ReferenceOption.CASCADE)
}