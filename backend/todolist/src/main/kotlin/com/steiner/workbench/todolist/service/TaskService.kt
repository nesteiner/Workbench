package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.common.formatDateFormat
import com.steiner.workbench.common.parseDateFormat
import com.steiner.workbench.todolist.model.Task
import com.steiner.workbench.todolist.request.PostTaskRequest
import com.steiner.workbench.todolist.request.PostTaskTagRequest
import com.steiner.workbench.todolist.request.UpdateTaskRequest
import com.steiner.workbench.todolist.table.SubTasks
import com.steiner.workbench.todolist.table.TaskGroups
import com.steiner.workbench.todolist.table.TaskTag
import com.steiner.workbench.todolist.table.Tasks
import com.steiner.workbench.todolist.util.mustExistIn
import com.steiner.workbench.common.util.now
import kotlinx.datetime.Instant
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class TaskService {
    @Autowired
    lateinit var tagService: TagService
    @Autowired
    lateinit var subtaskService: SubTaskService

    fun insertOne(request: PostTaskRequest): Task {
        mustExistIn(request.parentid, TaskGroups)

        Tasks.update({ Tasks.parentid eq request.parentid }) {
            with (SqlExpressionBuilder) {
                it.update(index, index + 1)
            }
        }

        val nowInstant = now()
        val id = Tasks.insert {
            it[name] = request.name
            it[index] = 1
            it[isdone] = false
            it[parentid] = request.parentid
            if (request.note != null) {
                it[note] = request.note
            }

            it[createTime] = nowInstant
            it[updateTime] = nowInstant

            it[priority] = request.priority

            it[expectTime] = request.expectTime
            it[finishTime] = 0

            if (request.deadline != null) {
                it[deadline] = parseFrom(request.deadline)
            }

            if (request.notifyTime != null) {
                it[notifyTime] = parseFrom(request.notifyTime)
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

    fun insertTag(request: PostTaskTagRequest) {
        TaskTag.insert {
            it[taskid] = request.taskid
            it[tagid] = request.tagid
        }
    }

    fun deleteOne(id: Int) {
        SubTasks.deleteWhere {
            parentid eq id
        }

        TaskTag.deleteWhere {
            taskid eq id
        }

        val taskIndex = Tasks
                .slice(Tasks.index)
                .select(Tasks.id eq id)
                .first()
                .let {
                    it[Tasks.index]
                }

        Tasks.deleteWhere {
            Tasks.id eq id
        }

        Tasks.update({ Tasks.index greater taskIndex}) {
            with (SqlExpressionBuilder) {
                it.update(index, index - 1)
            }
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
        mustExistIn(request.id, Tasks)
        mustExistIn(request.parentid, TaskGroups)

        if (request.reorderAt != null && request.parentid != null) {
            val (currentIndex, parentid) = Tasks.slice(Tasks.index, Tasks.parentid)
                    .select(Tasks.id eq request.id)
                    .first()
                    .let {
                        listOf(it[Tasks.index], it[Tasks.parentid].value)
                    }

            Tasks.update({ (Tasks.parentid eq parentid) and (Tasks.index greater currentIndex)}) {
                with (SqlExpressionBuilder) {
                    it.update(index, index - 1);
                }
            }

            Tasks.update({ (Tasks.parentid eq request.parentid) and (Tasks.index greaterEq request.reorderAt) }) {
                with (SqlExpressionBuilder) {
                    it.update(index, index + 1)
                }
            }

        } else if (request.reorderAt != null && request.parentid == null) {
            val (currentIndex, parentid) = Tasks.slice(Tasks.index, Tasks.parentid).select(Tasks.id eq request.id).first().let {
                listOf(it[Tasks.index], it[Tasks.parentid].value)
            }

            if (currentIndex < request.reorderAt) {
                Tasks.update(
                        {
                            (Tasks.parentid eq parentid) and (Tasks.index lessEq request.reorderAt) and (Tasks.index greater currentIndex)
                        }) {
                    with (SqlExpressionBuilder) {
                        it.update(index, index - 1)
                    }
                }
            } else if (currentIndex > request.reorderAt) {
                Tasks.update(
                        {
                            (Tasks.parentid eq parentid) and (Tasks.index greaterEq request.reorderAt) and (Tasks.index less currentIndex)
                        }) {
                    with(SqlExpressionBuilder) {
                        it.update(index, index + 1)
                    }
                }
            }
        }

        Tasks.update({ Tasks.id eq request.id }) {
            if (request.reorderAt != null) {
                it[index] = request.reorderAt
            }

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
                it[deadline] = parseFrom(request.deadline)
            }

            if (request.notifyTime != null) {
                it[notifyTime] = parseFrom(request.notifyTime)
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

            it[updateTime] = now()
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
                            index = it[Tasks.index],
                            name = it[Tasks.name],
                            isdone =  it[Tasks.isdone],
                            priority = it[Tasks.priority],
                            subtasks = subtaskService.findAll(taskid),
                            createTime = it[Tasks.createTime],
                            updateTime = it[Tasks.updateTime],

                            expectTime = it[Tasks.expectTime],
                            finishTime = it[Tasks.finishTime],
                            deadline = it[Tasks.deadline],
                            notifyTime = it[Tasks.notifyTime],
                            note = it[Tasks.note],
                            tags = tagService.findAllOfTask(taskid),
                            parentid = it[Tasks.parentid].value
                    )

                }
    }

    fun findAll(taskgroupid: Int): List<Task> {
        return Tasks.select(Tasks.parentid eq taskgroupid)
                .orderBy(Tasks.index)
                .map {
                    val taskid = it[Tasks.id].value
                    Task(
                            id = taskid,
                            name = it[Tasks.name],
                            index = it[Tasks.index],
                            isdone =  it[Tasks.isdone],
                            priority = it[Tasks.priority],
                            subtasks = subtaskService.findAll(taskid),
                            createTime = it[Tasks.createTime],
                            updateTime = it[Tasks.updateTime],

                            expectTime = it[Tasks.expectTime],
                            finishTime = it[Tasks.finishTime],
                            deadline = it[Tasks.deadline],

                            notifyTime = it[Tasks.notifyTime],

                            note = it[Tasks.note],
                            tags = tagService.findAllOfTask(taskid),
                            parentid = it[Tasks.parentid].value
                    )
                }
    }

    fun removeDeadline(id: Int) {
        Tasks.update({ Tasks.id eq id }) {
            it[deadline] = null
        }
    }

    fun removeNotifyTime(id: Int) {
        Tasks.update({ Tasks.id eq id }) {
            it[notifyTime] = null
        }
    }

    fun removeTag(taskid0: Int, tagid0: Int) {
        TaskTag.deleteWhere {
            (tagid eq tagid0) and (taskid eq taskid0)
        }
    }
    private fun parseFrom(datetimeString: String): Instant {
        val datetime = parseDateFormat.parse(datetimeString)
        val isostring = formatDateFormat.format(datetime)
        return Instant.parse(isostring)
    }
}