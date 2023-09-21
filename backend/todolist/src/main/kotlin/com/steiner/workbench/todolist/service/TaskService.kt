package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.todolist.model.Task
import com.steiner.workbench.todolist.model.TaskPriority
import com.steiner.workbench.todolist.request.PostTaskRequest
import com.steiner.workbench.todolist.request.UpdateTaskRequest
import com.steiner.workbench.todolist.table.SubTasks
import com.steiner.workbench.todolist.table.TaskGroups
import com.steiner.workbench.todolist.table.TaskTag
import com.steiner.workbench.todolist.table.Tasks
import com.steiner.workbench.todolist.util.mustExistIn
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.jetbrains.exposed.sql.deleteWhere

import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.select
import org.jetbrains.exposed.sql.update
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.sql.Timestamp

@Service
@Transactional
class TaskService {
    @Autowired
    lateinit var tagService: TagService
    @Autowired
    lateinit var subtaskService: SubTaskService

    fun insertOne(request: PostTaskRequest): Task {
        mustExistIn(request.parentid, TaskGroups)

        val id = Tasks.insert {
            it[name] = request.name
            it[isdone] = false
            it[parentid] = request.parentid
            if (request.note != null) {
                it[note] = request.note
            }

            val now = Clock.System.now()
            it[createTime] = now
            it[updateTime] = now

            it[priority] = request.priority

            it[expectTime] = request.expectTime
            it[finishTime] = 0

            if (request.deadline != null) {
                it[deadline] = Instant.parse(request.deadline)
            }

            if (request.notifyTime != null) {
                it[notifyTime] = Instant.parse(request.notifyTime)
            }
        } get Tasks.id

        request.tags?.forEach { tag ->
            TaskTag.insert {
                it[taskid]= id
                it[tagid] = tag.id
            }
        }

        return findOne(id.value)!!
    }

    fun deleteOne(id: Int) {
        SubTasks.deleteWhere {
            parentid eq id
        }

        TaskTag.deleteWhere {
            taskid eq id
        }

        Tasks.deleteWhere {
            Tasks.id eq id
        }
    }

    fun deleteAll(groupid: Int) {
        val taskids = Tasks.slice(Tasks.id).select(Tasks.parentid eq groupid).map {
            it[Tasks.id]
        }

        SubTasks.deleteWhere {
            parentid.inList(taskids)
        }

        TaskTag.deleteWhere {
            taskid.inList(taskids)
        }

        Tasks.deleteWhere {
            Tasks.id.inList(taskids)
        }

    }

    fun updateOne(request: UpdateTaskRequest): Task {
        Tasks.update({ Tasks.id eq request.id }) {
            if (request.name != null) {
                it[name] = request.name
            }

            if (request.isdone != null) {
                it[isdone] = request.isdone
            }

            if (request.deadline != null) {
                it[deadline] = Instant.parse(request.deadline)
            }

            if (request.notifyTime != null) {
                it[notifyTime] = Instant.parse(request.notifyTime)
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

            if (request.parentid != null) {
                it[parentid] = request.parentid
            }
        }

        return findOne(request.id) ?: throw BadRequestException("no such task")
    }

    fun findOne(id: Int): Task? {
        return Tasks.select(Tasks.id eq id)
                .firstOrNull()
                ?.let {
                    val taskid = it[Tasks.id].value
                    Task(
                            id = taskid,
                            name = it[Tasks.name],
                            isdone =  it[Tasks.isdone],
                            priority = it[Tasks.priority].let { priority ->
                                when (priority) {
                                    0 -> TaskPriority.LOW
                                    1 -> TaskPriority.NORMAL
                                    2 -> TaskPriority.HIGH
                                    else -> TaskPriority.UNKNOWN
                                }
                            },

                            subtasks = subtaskService.findAll(taskid),
                            createTime = it[Tasks.createTime].let {
                                Timestamp.valueOf(it.toString())
                            },

                            updateTime = it[Tasks.updateTime].let {
                                Timestamp.valueOf(it.toString())
                            },

                            expectTime = it[Tasks.expectTime],
                            finishTime = it[Tasks.finishTime],
                            deadline = it[Tasks.deadline]?.let {
                                Timestamp.valueOf(it.toString())
                            },

                            notifyTime = it[Tasks.notifyTime]?.let {
                                Timestamp.valueOf(it.toString())
                            },

                            note = it[Tasks.note],
                            tags = tagService.findAllOfTask(taskid)
                    )

                }
    }

    fun findAll(taskgroupid: Int): List<Task> {
        return Tasks.select(Tasks.parentid eq taskgroupid)
                .map {
                    val taskid = it[Tasks.id].value
                    Task(
                            id = taskid,
                            name = it[Tasks.name],
                            isdone =  it[Tasks.isdone],
                            priority = it[Tasks.priority].let { priority ->
                                when (priority) {
                                    0 -> TaskPriority.LOW
                                    1 -> TaskPriority.NORMAL
                                    2 -> TaskPriority.HIGH
                                    else -> TaskPriority.UNKNOWN
                                }
                            },

                            subtasks = subtaskService.findAll(taskid),
                            createTime = it[Tasks.createTime].let {
                                Timestamp.valueOf(it.toString())
                            },

                            updateTime = it[Tasks.updateTime].let {
                                Timestamp.valueOf(it.toString())
                            },

                            expectTime = it[Tasks.expectTime],
                            finishTime = it[Tasks.finishTime],
                            deadline = it[Tasks.deadline]?.let {
                                Timestamp.valueOf(it.toString())
                            },

                            notifyTime = it[Tasks.notifyTime]?.let {
                                Timestamp.valueOf(it.toString())
                            },

                            note = it[Tasks.note],
                            tags = tagService.findAllOfTask(taskid)
                    )
                }
    }
}