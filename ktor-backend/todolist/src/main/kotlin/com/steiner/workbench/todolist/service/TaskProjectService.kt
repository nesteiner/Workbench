package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.util.dbQuery
import com.steiner.workbench.common.util.now
import com.steiner.workbench.login.table.Users
import com.steiner.workbench.todolist.model.TaskProject
import com.steiner.workbench.todolist.request.PostTaskProjectRequest
import com.steiner.workbench.todolist.request.UpdateTaskProjectRequest
import com.steiner.workbench.todolist.table.TaskProjects
import com.steiner.workbench.todolist.util.mustExistIn
import io.ktor.server.plugins.*
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.jetbrains.exposed.sql.transactions.transaction

class TaskProjectService(val database: Database, val taskGroupService: TaskGroupService, val tagService: TagService) {
    init {
        transaction(database) {
            SchemaUtils.create(TaskProjects)
        }
    }

    suspend fun insertOne(request: PostTaskProjectRequest): TaskProject = dbQuery(database) {
        mustExistIn(request.userid, Users)

        val exist = with (TaskProjects) {
            selectAll().where(name eq request.name)
                .firstOrNull() != null
        }

        if (exist) {
            throw BadRequestException("duplicate name of taskproject")
        }

        with (TaskProjects) {
            update({ userid eq request.userid }) {
                with (SqlExpressionBuilder) {
                    it.update(index, index + 1)
                }
            }
        }

        val nowLocalDateTime = now()
        val id = with (TaskProjects) {
            insert {
                it[name] = request.name
                it[index] = 0
                it[avatarid] = request.avatarid
                it[userid] = request.userid
                it[createTime] = nowLocalDateTime
                it[updateTime] = nowLocalDateTime

                if (request.profile != null) {
                    it[profile] = request.profile
                }
            } get this.id
        }

        findOne(id.value)!!
    }

    suspend fun deleteOne(id: Int) = dbQuery(database) {
        tagService.deleteAll(id)
        taskGroupService.deleteAll(id)

        with (TaskProjects) {
            deleteWhere {
                this.id eq id
            }
        }
    }


    suspend fun deleteAll(userid: Int) = dbQuery(database) {
        val projectids = with (TaskProjects) {
            selectAll().where(this.userid eq userid)
                .map {
                    it[id]
                }
        }

        projectids.forEach {
            tagService.deleteAll(it.value)
            taskGroupService.deleteAll(it.value)
        }

        with (TaskProjects) {
            deleteWhere {
                id.inList(projectids)
            }
        }
    }

    suspend fun updateOne(request: UpdateTaskProjectRequest): TaskProject = dbQuery(database) {
        mustExistIn(request.id, TaskProjects)

        with (TaskProjects) {
            update({ id eq request.id }) {
                if (request.name != null) {
                    it[name] = request.name
                }

                if (request.avatarid != null) {
                    it[avatarid] = request.avatarid
                }

                it[updateTime] = now()

                if (request.profile != null) {
                    it[profile] = request.profile
                }
            }
        }

        findOne(request.id)!!
    }

    suspend fun findOne(id: Int): TaskProject? = dbQuery(database) {
        with (TaskProjects) {
            selectAll().where(this.id eq id)
                .firstOrNull()
                ?.let {
                    TaskProject(
                        id = id,
                        name = it[name],
                        index = it[index],
                        avatarid = it[avatarid]?.value,
                        profile = it[profile],
                        userid = it[userid].value,
                        createTime = it[createTime],
                        updateTime = it[updateTime]
                    )
                }
        }
    }

    suspend fun findAll(userid: Int): List<TaskProject> = dbQuery(database) {
        with (TaskProjects) {
            selectAll().where(this.userid eq userid)
                .orderBy(index)
                .map {
                    val id = it[id].value
                    findOne(id)!!
                }
        }
    }

    suspend fun clear() = dbQuery(database) {
        TaskProjects.deleteAll()
    }
}