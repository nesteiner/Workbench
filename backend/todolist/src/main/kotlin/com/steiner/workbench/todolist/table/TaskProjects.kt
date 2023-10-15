package com.steiner.workbench.todolist.table

import com.steiner.workbench.common.TASK_PROJECT_NAME_LENGTH
import com.steiner.workbench.login.table.Users
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.kotlin.datetime.timestamp

object TaskProjects: IntIdTable() {
    val index = integer("index")
    val name = varchar("name", TASK_PROJECT_NAME_LENGTH).uniqueIndex()
    val avatarid = reference("avatarid", ImageItems)
    val userid = reference("userid", Users)
    val profile = text("profile").nullable()
    val createTime = timestamp("createTime")
    val updateTime = timestamp("updateTime")
}