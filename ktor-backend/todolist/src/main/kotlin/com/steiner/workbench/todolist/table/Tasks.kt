package com.steiner.workbench.todolist.table

import com.steiner.workbench.todolist.model.Priority
import kotlinx.serialization.json.Json
import com.steiner.workbench.common.`task-name-length`
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.json.jsonb
import org.jetbrains.exposed.sql.kotlin.datetime.datetime

private val formatter = Json {
    ignoreUnknownKeys = true
}

object Tasks: IntIdTable("todolist-tasks") {
    val index = integer("index")
    val name = varchar("name", `task-name-length`)
    val isdone = bool("isdone")
    val priority = jsonb<Priority>("priority", formatter)
    val note = text("note").nullable()
    val parentid = reference("parentid", TaskGroups, onDelete = ReferenceOption.CASCADE)
    val createTime = datetime("create-time")
    val updateTime = datetime("update-time")

    val expectTime = integer("expect-time")
    val finishTime = integer("finish-time")
    val deadline = datetime("deadline").nullable()
    val notifyTime = datetime("notifyTime").nullable()
}