package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.util.dbQuery
import com.steiner.workbench.todolist.model.SubTask
import com.steiner.workbench.todolist.request.PostSubTaskRequest
import com.steiner.workbench.todolist.request.UpdateSubTaskRequest
import com.steiner.workbench.todolist.table.SubTasks
import com.steiner.workbench.todolist.table.Tasks
import com.steiner.workbench.todolist.util.mustExistIn
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction

class SubTaskService(val database: Database) {
    init {
        transaction(database) {
            SchemaUtils.create(SubTasks)
        }
    }

    suspend fun insertOne(request: PostSubTaskRequest): SubTask = dbQuery(database) {
        mustExistIn(request.parentid, Tasks)

        with (SubTasks) {
            update({ parentid eq request.parentid}) {
                with (SqlExpressionBuilder) {
                    it.update(index, index + 1)
                }
            }
        }

        val id = with (SubTasks) {
            insert {
                it[index] = 0
                it[parentid] = request.parentid
                it[name] = request.name
                it[isdone] = false
            } get this.id
        }

        findOne(id.value)!!
    }

    suspend fun deleteOne(id: Int) = dbQuery(database) {
        with (SubTasks) {
            deleteWhere {
                this.id eq id
            }
        }
    }

    suspend fun deleteAll(taskid: Int) = dbQuery(database) {
        with (SubTasks) {
            deleteWhere {
                parentid eq taskid
            }
        }
    }

    suspend fun updateOne(request: UpdateSubTaskRequest): SubTask = dbQuery(database) {
        mustExistIn(request.id, SubTasks)

        with (SubTasks) {
            update({ id eq request.id }) {
                if (request.name != null) {
                    it[name] = request.name
                }

                if (request.isdone != null) {
                    it[isdone] = request.isdone
                }
            }
        }

        findOne(request.id)!!
    }

    suspend fun findOne(id: Int): SubTask? = dbQuery(database) {
        with (SubTasks) {
            selectAll().where(this.id eq id)
                .firstOrNull()
                ?.let {
                    SubTask(
                        id = id,
                        name = it[name],
                        index = it[index],
                        isdone = it[isdone],
                        parentid = it[parentid].value
                    )
                }
        }
    }

    suspend fun findAll(parentid: Int): List<SubTask> = dbQuery(database) {
        with (SubTasks) {
            selectAll().where(this.parentid eq parentid)
                .orderBy(index)
                .map {
                    SubTask(
                        id = it[id].value,
                        name = it[name],
                        index = it[index],
                        isdone = it[isdone],
                        parentid = parentid
                    )
                }
        }
    }

    suspend fun clear() = dbQuery(database) {
        SubTasks.deleteAll()
    }
}