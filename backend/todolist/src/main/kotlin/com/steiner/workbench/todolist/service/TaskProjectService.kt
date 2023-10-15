package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.DEFAULT_AVATAR_ID
import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.common.util.Page
import com.steiner.workbench.login.table.Users
import com.steiner.workbench.todolist.model.TaskProject
import com.steiner.workbench.todolist.request.PostTaskProjectRequest
import com.steiner.workbench.todolist.request.UpdateTaskProjectRequest
import com.steiner.workbench.todolist.table.TaskProjects
import com.steiner.workbench.todolist.util.mustExistIn
import com.steiner.workbench.todolist.util.now
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import kotlin.math.ceil

@Service
@Transactional
class TaskProjectService {
    @Autowired
    lateinit var taskgroupService: TaskGroupService
    @Autowired
    lateinit var tagService: TagService

    fun insertOne(request: PostTaskProjectRequest): TaskProject {
        mustExistIn(request.userid, Users)
        val iftaskgroup = TaskProjects
                .slice(TaskProjects.id)
                .select(TaskProjects.name eq request.name)
                .firstOrNull()

        if (iftaskgroup != null) {
            throw BadRequestException("duplicate name of taskproject")
        }

        TaskProjects.update({ TaskProjects.userid eq request.userid }) {
            with (SqlExpressionBuilder) {
                it.update(index, index + 1)
            }
        }

        val nowInstant = now()
        val id = TaskProjects.insert {
            it[name] = request.name
            it[index] = 1
            it[avatarid] = request.avatarid ?: DEFAULT_AVATAR_ID
            it[userid] = request.userid
            it[createTime] = nowInstant
            it[updateTime] = nowInstant

            if (request.profile != null) {
                it[profile] = request.profile
            }
        } get TaskProjects.id

        return findOne(id.value)!!
    }

    fun deleteOne(id: Int) {
        tagService.deleteAll(id)
        taskgroupService.deleteAll(id)

        TaskProjects.deleteWhere {
            TaskProjects.id eq id
        }
    }

    fun deleteAll(userid: Int) {
        val projectids = TaskProjects.slice(TaskProjects.id).select(TaskProjects.userid eq userid).map {
            it[TaskProjects.id]
        }

        projectids.forEach {
            tagService.deleteAll(it.value)
            taskgroupService.deleteAll(it.value)
        }

        TaskProjects.deleteWhere {
            TaskProjects.id.inList(projectids)
        }

    }

    fun updateOne(request: UpdateTaskProjectRequest): TaskProject {
        mustExistIn(request.id, TaskProjects)

        TaskProjects.update({ TaskProjects.id eq request.id }) {
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

        return findOne(request.id)!!
    }

    fun findOne(id: Int): TaskProject? {
        return TaskProjects.select(TaskProjects.id eq id)
                .firstOrNull()
                ?.let {
                    TaskProject(
                            id = id,
                            name = it[TaskProjects.name],
                            index = it[TaskProjects.index],
                            avatarid = it[TaskProjects.avatarid].value,
                            profile = it[TaskProjects.profile],
                            userid = it[TaskProjects.userid].value,
                            createTime = it[TaskProjects.createTime],
                            updateTime = it[TaskProjects.updateTime]
                    )
                }
    }

    fun findAll(userid: Int): List<TaskProject> {
        return TaskProjects.select(TaskProjects.userid eq userid)
                .orderBy(TaskProjects.index)
                .map {
                    val projectid = it[TaskProjects.id].value
                    TaskProject(
                            id = projectid,
                            name = it[TaskProjects.name],
                            index = it[TaskProjects.index],
                            avatarid = it[TaskProjects.avatarid].value,
                            profile = it[TaskProjects.profile],
                            userid = userid,
                            createTime = it[TaskProjects.createTime],
                            updateTime = it[TaskProjects.updateTime]
                    )
                }
    }

    fun findAll(userid: Int, page: Int, size: Int): Page<TaskProject> {
        val content = TaskProjects.select(TaskProjects.userid eq userid)
                .limit(size, offset = page * size.toLong())
                .map {
                    val projectid = it[TaskProjects.id].value
                    TaskProject(
                            id = projectid,
                            name = it[TaskProjects.name],
                            index = it[TaskProjects.index],
                            avatarid = it[TaskProjects.avatarid].value,
                            profile = it[TaskProjects.profile],
                            userid = userid,
                            createTime = it[TaskProjects.createTime],
                            updateTime = it[TaskProjects.updateTime]
                    )
                }

        val totalPages = ceil(TaskProjects.selectAll().count() / size.toDouble()).toInt()

        return Page(content, totalPages)
    }
}