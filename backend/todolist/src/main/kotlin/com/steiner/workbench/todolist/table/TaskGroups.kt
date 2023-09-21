package com.steiner.workbench.todolist.table

import com.steiner.workbench.common.TASK_GROUP_NAME_LENGTH
import org.jetbrains.exposed.dao.id.IntIdTable

object TaskGroups: IntIdTable() {
    val name = varchar("name", TASK_GROUP_NAME_LENGTH)
    val parentid = reference("parentid", TaskProjects)
}