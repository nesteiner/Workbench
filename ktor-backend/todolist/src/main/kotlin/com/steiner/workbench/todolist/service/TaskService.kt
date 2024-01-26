package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.util.dbQuery
import com.steiner.workbench.common.util.now
import com.steiner.workbench.todolist.model.Task
import com.steiner.workbench.todolist.request.PostTaskRequest
import com.steiner.workbench.todolist.request.PostTaskTagRequest
import com.steiner.workbench.todolist.request.UpdateTaskRequest
import com.steiner.workbench.todolist.table.*
import com.steiner.workbench.todolist.util.mustExistIn
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.jetbrains.exposed.sql.transactions.transaction

class TaskService(val database: Database, val tagService: TagService, val subtaskService: SubTaskService) {
    init {
        transaction(database) {
            SchemaUtils.create(Tasks)
        }
    }

    suspend fun insertOne(request: PostTaskRequest): Task = dbQuery(database) {
        mustExistIn(request.parentid, TaskGroups)

        with (Tasks) {
            update({ parentid eq request.parentid }) {
                with (SqlExpressionBuilder) {
                    it.update(index, index + 1)
                }
            }
        }

        val nowLocalDateTime = now()
        val id = with (Tasks) {
            insert {
                it[name] = request.name
                it[index] = 0
                it[isdone] = false
                it[parentid] = request.parentid
                if (request.note != null) {
                    it[note] = request.note
                }

                it[createTime] = nowLocalDateTime
                it[updateTime] = nowLocalDateTime

                it[priority] = request.priority
                it[expectTime] = request.expectTime
                it[finishTime] = 0

                if (request.deadline != null) {
                    it[deadline] = request.deadline
                }

                if (request.notifyTime != null) {
                    it[notifyTime] = request.notifyTime
                }
            } get this.id

        }

        findOne(id.value)!!
    }

    suspend fun insertTag(request: PostTaskTagRequest) = dbQuery(database) {
        mustExistIn(request.tagid, Tags)
        mustExistIn(request.taskid, Tasks)

        val exist = with (TaskTag) {
            selectAll().where(tagid eq request.tagid)
                .firstOrNull() != null
        }

        if (!exist) {
            with (TaskTag) {
                insert {
                    it[taskid] = request.taskid
                    it[tagid] = request.tagid
                }
            }
        }
    }

    suspend fun deleteOne(id: Int) = dbQuery(database) {
        with (TaskTag) {
            deleteWhere {
                taskid eq id
            }
        }

        with (Tasks) {
            deleteWhere {
                this.id eq id
            }
        }
    }

    suspend fun deleteAll(parentid: Int) = dbQuery(database) {
        val taskids = with (Tasks) {
            selectAll().where(this.parentid eq parentid)
                .map {
                    it[this.id]
                }
        }

        SubTasks.deleteWhere {
            this.parentid.inList(taskids)
        }

        TaskTag.deleteWhere {
            taskid.inList(taskids)
        }

        with (Tasks) {
            deleteWhere {
                id.inList(taskids)
            }
        }
    }

    suspend fun removeTag(taskid: Int, tagid: Int) = dbQuery(database) {
        with (TaskTag) {
            deleteWhere {
                (this.tagid eq tagid) and (this.taskid eq tagid)
            }
        }
    }

    suspend fun removeDeadline(id: Int) = dbQuery(database) {
        with (Tasks) {
            update({ this@with.id eq id }) {
                it[deadline] = null
            }
        }
    }

    suspend fun removeNotifyTime(id: Int) = dbQuery(database) {
        with (Tasks) {
            update({ this@with.id eq id}) {
                it[notifyTime] = null
            }
        }
    }

    suspend fun updateTask(request: UpdateTaskRequest): Task = dbQuery(database) {
        mustExistIn(request.id, Tasks)
        mustExistIn(request.parentid, TaskGroups)

        with (Tasks) {
            update({ id eq request.id}) {
                if (request.parentid != null) {
                    it[parentid] = request.parentid
                }

                if (request.name != null) {
                    it[name] = request.name
                }

                if (request.isdone != null) {
                    it[isdone] = request.isdone
                }

                if (request.deadline != null) {
                    it[deadline] = deadline
                }

                if (request.notifyTime != null) {
                    it[notifyTime] = request.notifyTime
                }

                if (request.note != null) {
                    it[note] = request.note
                }

                if (request.priority != null) {
                    it[priority] = request.priority
                }

                if (request.expectTime != null) {
                    it[expectTime] = request.expectTime
                }

                if (request.finishTime != null) {
                    it[finishTime] = request.finishTime
                }

                it[updateTime] = now()
            }
        }

        findOne(request.id)!!
    }

    suspend fun findOne(id: Int): Task? = dbQuery(database) {
        with (Tasks) {
            selectAll().where(this.id eq id)
                .firstOrNull()
                ?.let {
                    Task(
                        id = id,
                        index = it[index],
                        name = it[name],
                        isdone = it[isdone],
                        priority = it[priority],
                        subtasks = subtaskService.findAll(id),
                        createTime = it[createTime],
                        updateTime = it[updateTime],
                        expectTime = it[expectTime],
                        finishTime = it[finishTime],
                        deadline = it[deadline],
                        notifyTime = it[notifyTime],
                        note = it[note],
                        parentid = it[parentid].value,
                        tags = tagService.findAllOfTask(id)
                    )
                }
        }
    }

    suspend fun findAll(parentid: Int): List<Task> = dbQuery(database) {
        mustExistIn(parentid, TaskGroups)

        with (Tasks) {
            selectAll().where(this.parentid eq parentid)
                .map {
                    findOne(it[id].value)!!
                }
        }
    }

    suspend fun clear() = dbQuery(database) {
        Tasks.deleteAll()
    }
}