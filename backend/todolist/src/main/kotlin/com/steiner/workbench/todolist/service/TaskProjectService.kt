package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.DEFAULT_AVATAR_ID
import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.common.util.Page
import com.steiner.workbench.login.table.Users
import com.steiner.workbench.todolist.model.TaskProject
import com.steiner.workbench.todolist.request.PostTaskProjectRequest
import com.steiner.workbench.todolist.request.UpdateTaskProjectRequest
import com.steiner.workbench.todolist.table.TaskGroups
import com.steiner.workbench.todolist.table.TaskProjects
import com.steiner.workbench.todolist.util.mustExistIn
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

        val id = TaskProjects.insert {
            it[name] = request.name
            it[avatarid] = request.avatarid ?: DEFAULT_AVATAR_ID

            it[userid] = request.userid
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
        TaskProjects.update({ TaskProjects.id eq request.id }) {
            if (request.name != null) {
                it[name] = request.name
            }

            if (request.avatarid != null) {
                it[avatarid] = request.avatarid
            }
        }

        return findOne(request.id) ?: throw BadRequestException("no such task project")
    }

    fun findOne(id: Int): TaskProject? {
        return TaskProjects.select(TaskProjects.id eq id)
                .firstOrNull()
                ?.let {
                    TaskProject(
                            id = id,
                            name = it[TaskProjects.name],
                            avatarid = it[TaskProjects.avatarid].value,
                            userid = it[TaskProjects.userid].value
                    )
                }
    }

    fun findAll(userid: Int): List<TaskProject> {
        return TaskProjects.select(TaskProjects.userid eq userid)
                .map {
                    val projectid = it[TaskProjects.id].value
                    TaskProject(
                            id = projectid,
                            name = it[TaskProjects.name],
                            avatarid = it[TaskProjects.avatarid].value,
                            userid = userid
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
                            avatarid = it[TaskProjects.avatarid].value,
                            userid = userid
                    )
                }

        val totalPages = ceil(TaskProjects.selectAll().count() / size.toDouble()).toInt()

        return Page(content, totalPages)
    }
}