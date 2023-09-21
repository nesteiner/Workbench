package com.steiner.workbench.todolist.table

import com.steiner.workbench.common.TASK_PROJECT_NAME_LENGTH
import com.steiner.workbench.login.table.Users
import org.jetbrains.exposed.dao.id.IntIdTable

object TaskProjects: IntIdTable() {
    val name = varchar("name", TASK_PROJECT_NAME_LENGTH)
    val avatarid = reference("avatarid", ImageItems)
    val userid = reference("userid", Users)
}