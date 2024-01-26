package com.steiner.workbench.todolist.table

import com.steiner.workbench.common.table.ImageItems
import com.steiner.workbench.login.table.Users
import com.steiner.workbench.common.`task-project-name-length`
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.kotlin.datetime.datetime

object TaskProjects: IntIdTable("todolist-taskprojects") {
    val index = integer("index")
    val name = varchar("name", `task-project-name-length`).uniqueIndex()
    val avatarid = reference("avatarid", ImageItems).nullable()
    val userid = reference("userid", Users, onDelete = ReferenceOption.CASCADE)
    val profile = text("profile").nullable()
    val createTime = datetime("create-time")
    val updateTime = datetime("update-time")
}