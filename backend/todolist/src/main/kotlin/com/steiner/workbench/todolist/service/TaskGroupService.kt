package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.todolist.model.TaskGroup
import com.steiner.workbench.todolist.request.PostTaskGroupRequest
import com.steiner.workbench.todolist.request.UpdateTaskGroupRequest
import com.steiner.workbench.todolist.table.TaskGroups
import com.steiner.workbench.todolist.table.TaskProjects
import com.steiner.workbench.todolist.table.Tasks
import com.steiner.workbench.todolist.util.mustExistIn
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.jetbrains.exposed.sql.deleteWhere
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.select
import org.jetbrains.exposed.sql.update
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class TaskGroupService {
    @Autowired
    lateinit var taskService: TaskService
    fun insertOne(request: PostTaskGroupRequest): TaskGroup {
        mustExistIn(request.parentid, TaskProjects)

        val id = TaskGroups.insert {
            it[parentid] = request.parentid
            it[name] = request.name
        } get TaskGroups.id

        return TaskGroup(
                id = id.value,
                name = request.name,
                tasks = listOf()
        )
    }

    fun deleteOne(id: Int) {
        Tasks.deleteWhere {
            parentid eq id
        }

        TaskGroups.deleteWhere {
            TaskGroups.id eq id
        }
    }

    fun deleteAll(projectid: Int) {
        val groupids = TaskGroups.slice(TaskGroups.id).select(TaskGroups.parentid eq projectid).map {
            it[TaskGroups.id]
        }

        groupids.forEach {
            taskService.deleteAll(it.value)
        }

        TaskGroups.deleteWhere {
            TaskGroups.id.inList(groupids)
        }
    }

    fun updateOne(request: UpdateTaskGroupRequest): TaskGroup {
        TaskGroups.update({ TaskGroups.id eq request.id }) {
            it[name] = request.name
        }

        return findOne(request.id) ?: throw BadRequestException("no such taskgroup")
    }

    fun findOne(id: Int): TaskGroup? {
        return TaskGroups.select(TaskGroups.id eq id)
                .firstOrNull()
                ?.let {
                    val tasks = taskService.findAll(id)

                    TaskGroup(
                            id = id,
                            name = it[TaskGroups.name],
                            tasks = tasks
                    )
                }
    }

    fun findAll(projectid: Int): List<TaskGroup> {
        return TaskGroups.select(TaskGroups.parentid eq projectid)
                .map {
                    val id = it[TaskGroups.id].value
                    TaskGroup(
                            id = id,
                            name = it[TaskGroups.name],
                            tasks = taskService.findAll(id)
                    )
                }
    }
}