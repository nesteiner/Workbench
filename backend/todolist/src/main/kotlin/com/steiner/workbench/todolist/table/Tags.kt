package com.steiner.workbench.todolist.table

import com.steiner.workbench.common.TAG_NAME_LENGTH
import org.jetbrains.exposed.dao.id.IntIdTable

object Tags: IntIdTable() {
    val name = varchar("name", TAG_NAME_LENGTH).uniqueIndex()
    val parentid = reference("parentid", TaskProjects)
    val color = char("color", 24)
}