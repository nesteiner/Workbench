package com.steiner.workbench.todolist.table

import com.steiner.workbench.common.TASK_NAME_LENGTH
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.kotlin.datetime.timestamp

object Tasks: IntIdTable("todolist-tasks") {
    val index = integer("index")
    val name = varchar("name", TASK_NAME_LENGTH)
    val isdone = bool("isdone")
    val priority = integer("priority")
    val note = text("note").nullable()

    // parentid
    val parentid = reference("parentid", TaskGroups, onDelete = ReferenceOption.CASCADE)
    val createTime = timestamp("createTime")
    val updateTime = timestamp("updateTime")

    val expectTime = integer("expectTime")
    val finishTime = integer("finishTime")

    val deadline = timestamp("deadline").nullable()
    val notifyTime = timestamp("notifyTime").nullable()
}