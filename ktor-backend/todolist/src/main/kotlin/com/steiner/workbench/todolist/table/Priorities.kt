package com.steiner.workbench.todolist.table

import com.steiner.workbench.common.`priority-name-length`
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption

object Priorities: IntIdTable("todolist-priorities") {
    val name = varchar("name", `priority-name-length`)
    val order = integer("order")
    val parentid = reference("parentid", TaskProjects, onDelete = ReferenceOption.CASCADE)
}