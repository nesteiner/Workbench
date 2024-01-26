package com.steiner.workbench.todolist.table

import com.steiner.workbench.common.`task-group-name-length`
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.kotlin.datetime.datetime

object TaskGroups: IntIdTable("todolist-taskgroups") {
    val index = integer("index")
    val name = varchar("name", `task-group-name-length`)
    val parentid = reference("parentid", TaskProjects, onDelete = ReferenceOption.CASCADE)
    val createTime = datetime("create-time")
    val updateTime = datetime("update-time")
}