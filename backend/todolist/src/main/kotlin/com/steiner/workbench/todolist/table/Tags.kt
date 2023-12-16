package com.steiner.workbench.todolist.table

import com.steiner.workbench.common.TAG_NAME_LENGTH
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption

object Tags: IntIdTable("todolist-tags") {
    val name = varchar("name", TAG_NAME_LENGTH).uniqueIndex()
    val parentid = reference("parentid", TaskProjects, onDelete = ReferenceOption.CASCADE)
    val color = char("color", 24)
}