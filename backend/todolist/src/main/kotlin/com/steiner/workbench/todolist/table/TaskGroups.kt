package com.steiner.workbench.todolist.table

import com.steiner.workbench.common.TASK_GROUP_NAME_LENGTH
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.kotlin.datetime.timestamp

object TaskGroups: IntIdTable() {
    val index = integer("index")
    val name = varchar("name", TASK_GROUP_NAME_LENGTH)
    val parentid = reference("parentid", TaskProjects)
    val createTime = timestamp("createTime")
    val updateTime = timestamp("updateTime")
}