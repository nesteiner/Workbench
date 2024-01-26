package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.util.dbQuery
import com.steiner.workbench.common.util.now
import com.steiner.workbench.todolist.model.TaskGroup
import com.steiner.workbench.todolist.request.PostTaskGroupRequest
import com.steiner.workbench.todolist.request.UpdateTaskGroupRequest
import com.steiner.workbench.todolist.table.TaskGroups
import com.steiner.workbench.todolist.table.TaskProjects
import com.steiner.workbench.todolist.table.Tasks
import com.steiner.workbench.todolist.util.mustExistIn
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.jetbrains.exposed.sql.transactions.transaction

class TaskGroupService(val database: Database, val taskService: TaskService) {
    init {
        transaction(database) {
            SchemaUtils.create(TaskGroups)
        }
    }

    suspend fun insertOne(request: PostTaskGroupRequest): TaskGroup = dbQuery(database) {
        mustExistIn(request.parentid, TaskProjects)

        val count = TaskGroups.selectAll().count().toInt()
        val nowLocalDateTime = now()

        val id = with (TaskGroups) {
            insert {
                it[parentid] = request.parentid
                it[index] = count
                it[name] = request.name
                it[createTime] = nowLocalDateTime
                it[updateTime] = nowLocalDateTime
            } get this.id
        }

        findOne(id.value)!!
    }

    suspend fun insertOne(request: PostTaskGroupRequest, after: Int): TaskGroup = dbQuery(database) {
        mustExistIn(request.parentid, TaskProjects)
        with (TaskGroups) {
            update({ (parentid eq request.parentid) and (index greater after)}) {
                with (SqlExpressionBuilder) {
                    it.update(index, index + 1)
                }
            }

            val nowLocalDateTime = now()
            val id = insert {
                it[parentid] = request.parentid
                it[index] = after + 1
                it[name] = request.name
                it[createTime] = nowLocalDateTime
                it[updateTime] = nowLocalDateTime
            } get this.id

            findOne(id.value)!!
        }
    }

    suspend fun deleteOne(id: Int) = dbQuery(database) {
        mustExistIn(id, TaskGroups)

        Tasks.deleteWhere {
            parentid eq id
        }

        val index = with (TaskGroups) {
            selectAll().where(this.id eq id)
                .first()
                .let {
                    it[index]
                }
        }

        with (TaskGroups) {
            deleteWhere {
                this.id eq id
            }

            update({ this@with.index greater index }) {
                with (SqlExpressionBuilder) {
                    it.update(this@update.index, this@update.index - 1)
                }
            }
        }
    }

    suspend fun deleteAll(parentid: Int) = dbQuery(database) {
        val groupids = with (TaskGroups) {
            selectAll().where(this.parentid eq parentid)
                .map {
                    it[id]
                }
        }

        groupids.forEach {
            taskService.deleteAll(it.value)
        }

        with (TaskGroups) {
            deleteWhere {
                id.inList(groupids)
            }
        }
    }

    suspend fun updateOne(request: UpdateTaskGroupRequest): TaskGroup = dbQuery(database) {
        mustExistIn(request.id, TaskGroups)

        with (TaskGroups) {
            update({ id eq request.id}) {
                it[name] = request.name
                it[updateTime] = now()
            }
        }

        findOne(request.id)!!
    }

    suspend fun findOne(id: Int): TaskGroup? = dbQuery(database) {
        with (TaskGroups) {
            select(this.id eq id)
                .firstOrNull()
                ?.let {
                    val tasks = taskService.findAll(id)

                    TaskGroup(
                        id = id,
                        name = it[name],
                        index = it[index],
                        tasks = tasks,
                        createTime = it[createTime],
                        updateTime = it[updateTime],
                        parentid = it[parentid].value
                    )
                }
        }
    }

    suspend fun findAll(parentid: Int): List<TaskGroup> = dbQuery(database) {
        with (TaskGroups) {
            selectAll().where(this.parentid eq parentid)
                .orderBy(index)
                .map {
                    val id = it[id].value

                    TaskGroup(
                        id = id,
                        name = it[name],
                        index = it[index],
                        tasks = taskService.findAll(id),
                        createTime = it[createTime],
                        updateTime = it[updateTime],
                        parentid = it[this.parentid].value
                    )
                }
        }
    }

    suspend fun clear() = dbQuery(database) {
        TaskGroups.deleteAll()
    }
}