package com.steiner.workbench.todolist.service

import com.steiner.workbench.todolist.model.TaskGroup
import com.steiner.workbench.todolist.request.PostTaskGroupRequest
import com.steiner.workbench.todolist.request.UpdateTaskGroupRequest
import com.steiner.workbench.todolist.table.TaskGroups
import com.steiner.workbench.todolist.table.TaskProjects
import com.steiner.workbench.todolist.table.Tasks
import com.steiner.workbench.todolist.util.mustExistIn
import com.steiner.workbench.common.util.now
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class TaskGroupService {
    companion object {
        val logger = LoggerFactory.getLogger(TaskGroupService::class.java)
    }

    @Autowired
    lateinit var taskService: TaskService
    fun insertOne(request: PostTaskGroupRequest): TaskGroup {
        mustExistIn(request.parentid, TaskProjects)

        val count = TaskGroups.selectAll().count().toInt()

        val nowInstant = now()
        val id = TaskGroups.insert {
            it[parentid] = request.parentid
            it[index] = count + 1
            it[name] = request.name
            it[createTime] = nowInstant
            it[updateTime] = nowInstant
        } get TaskGroups.id

        return TaskGroup(
                id = id.value,
                name = request.name,
                index = count + 1,
                tasks = listOf(),
                createTime = nowInstant,
                updateTime = nowInstant,
                parentid = request.parentid
        )
    }

    fun insertOne(request: PostTaskGroupRequest, after: Int): TaskGroup {
        mustExistIn(request.parentid, TaskProjects)

        TaskGroups.update({ (TaskGroups.parentid eq request.parentid) and (TaskGroups.index greater after)}) {
            with (SqlExpressionBuilder) {
                it.update(index, index + 1)
            }
        }

        val nowInstant = now()
        val id = TaskGroups.insert {
            it[parentid] = request.parentid
            it[index] = after + 1
            it[name] = request.name
            it[createTime] = nowInstant
            it[updateTime] = nowInstant
        } get TaskGroups.id

        return TaskGroup(
                id = id.value,
                name = request.name,
                index = after + 1,
                tasks = listOf(),
                createTime = nowInstant,
                updateTime = nowInstant,
                parentid = request.parentid
        )
    }
    fun deleteOne(id: Int) {
        Tasks.deleteWhere {
            parentid eq id
        }

        val taskgroupIndex = TaskGroups
                .slice(TaskGroups.index)
                .select(TaskGroups.id eq id)
                .first()
                .let {
                    it[TaskGroups.index]
                }

        TaskGroups.deleteWhere {
            TaskGroups.id eq id
        }

        TaskGroups.update({ TaskGroups.index greater taskgroupIndex}) {
            with (SqlExpressionBuilder) {
                it.update(index, index - 1)
            }
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
        mustExistIn(request.id, TaskGroups)

        if (request.reorderAt != null) {
            val taskgroup = findOne(request.id)!!
            val currentIndex = taskgroup.index
            val parentid = taskgroup.parentid

            logger.info("reorder from $currentIndex to ${request.reorderAt}, the id is ${taskgroup.id}")

            if (currentIndex < request.reorderAt) {
                TaskGroups.update(
                        {
                            (TaskGroups.parentid eq parentid) and (TaskGroups.index lessEq request.reorderAt) and (TaskGroups.index greater currentIndex)
                        }) {
                    with (SqlExpressionBuilder) {
                        it.update(index, index - 1)
                    }
                }
            } else if (currentIndex > request.reorderAt) {
                TaskGroups.update(
                        {
                            (TaskGroups.parentid eq parentid) and (TaskGroups.index greaterEq request.reorderAt) and (TaskGroups.index less currentIndex)
                        }) {
                    with(SqlExpressionBuilder) {
                        it.update(index, index + 1)
                    }
                }
            } else {
                // empty else
            }
        }

        TaskGroups.update({ TaskGroups.id eq request.id }) {
            if (request.name != null) {
                it[name] = request.name
            }

            it[updateTime] = now()

            if (request.reorderAt != null) {
                it[index] = request.reorderAt
            }
        }

        return findOne(request.id)!!
    }

    fun findOne(id: Int): TaskGroup? {
        return TaskGroups.select(TaskGroups.id eq id)
                .firstOrNull()
                ?.let {
                    val tasks = taskService.findAll(id)

                    TaskGroup(
                            id = id,
                            name = it[TaskGroups.name],
                            index = it[TaskGroups.index],
                            tasks = tasks,
                            createTime = it[TaskGroups.createTime],
                            updateTime = it[TaskGroups.updateTime],
                            parentid = it[TaskGroups.parentid].value
                    )
                }
    }

    fun
            findAll(projectid: Int): List<TaskGroup> {
        return TaskGroups.select(TaskGroups.parentid eq projectid)
                .orderBy(TaskGroups.index)
                .map {
                    val id = it[TaskGroups.id].value
                    TaskGroup(
                            id = id,
                            name = it[TaskGroups.name],
                            index = it[TaskGroups.index],
                            tasks = taskService.findAll(id),
                            createTime = it[TaskGroups.createTime],
                            updateTime = it[TaskGroups.updateTime],
                            parentid = it[TaskGroups.parentid].value
                    )
                }
    }
}