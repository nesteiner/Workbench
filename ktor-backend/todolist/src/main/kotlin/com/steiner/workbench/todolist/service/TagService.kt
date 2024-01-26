package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.util.dbQuery
import com.steiner.workbench.todolist.model.Tag
import com.steiner.workbench.todolist.request.PostTagRequest
import com.steiner.workbench.todolist.request.UpdateTagRequest
import com.steiner.workbench.todolist.table.Tags
import com.steiner.workbench.todolist.table.Tags.select
import com.steiner.workbench.todolist.table.TaskProjects
import com.steiner.workbench.todolist.table.TaskTag
import com.steiner.workbench.todolist.util.mustExistIn
import io.ktor.server.plugins.*
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction

class TagService(val database: Database) {
    init {
        transaction(database) {
            SchemaUtils.create(Tags)
            SchemaUtils.create(TaskTag)
        }
    }

    suspend fun insertOne(request: PostTagRequest): Tag = dbQuery(database) {
        mustExistIn(request.parentid, TaskProjects)

        val iftag = with (Tags) {
            selectAll().where(name eq request.name)
                .firstOrNull()?.let {
                    Tag(
                        id = it[id].value,
                        name = it[name],
                        parentid = it[parentid].value,
                        color = it[color]
                    )
                }
        }

        if (iftag != null) {
            iftag
        } else {
            val id = with (Tags) {
                insert {
                    it[name] = request.name
                    it[parentid] = request.parentid
                    it[color] = request.color
                } get this.id
            }

            findOne(id.value)!!
        }

    }

    suspend fun deleteAll(parentid: Int) = dbQuery(database) {
        with (Tags) {
            deleteWhere {
                this.parentid eq parentid
            }
        }
    }

    suspend fun updateOne(request: UpdateTagRequest): Tag = dbQuery(database) {
        val exist = with (Tags) {
            selectAll().where(name eq request.name)
                .firstOrNull() != null
        }

        if (exist) {
            with (Tags) {
                update({ id eq request.id}) {
                    it[name] = request.name
                }
            }

            findOne(request.id)!!
        } else {
            throw BadRequestException("there is already a tag named ${request.name}")
        }
    }

    suspend fun findAllOfTask(taskid: Int): List<Tag> = dbQuery(database) {
        with (TaskTag) {
            selectAll().where(this.taskid eq taskid).map {
                val id = it[tagid]
                Tags.run {
                    selectAll().where(this.id eq id)
                        .first()
                        .let {
                            Tag(
                               id = id.value,
                                name = it[name],
                                parentid = it[parentid].value,
                                color = it[color]
                            )
                        }
                }
            }
        }
    }

    suspend fun findOne(id: Int): Tag? = dbQuery(database) {
        with (Tags) {
            selectAll().where(this.id eq id)
                .firstOrNull()
                ?.let {
                    Tag(
                        id = id,
                        name = it[name],
                        parentid = it[parentid].value,
                        color = it[color]
                    )
                }
        }
    }

    suspend fun clear() = dbQuery(database) {
        Tags.deleteAll()
    }
}