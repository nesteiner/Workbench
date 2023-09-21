package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.todolist.model.SubTask
import com.steiner.workbench.todolist.request.PostSubTaskRequest
import com.steiner.workbench.todolist.request.UpdateSubTaskRequest
import com.steiner.workbench.todolist.table.SubTasks
import com.steiner.workbench.todolist.table.Tasks
import com.steiner.workbench.todolist.util.mustExistIn
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.deleteWhere
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.select
import org.jetbrains.exposed.sql.update
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional


@Service
@Transactional
class SubTaskService {
    fun findAll(parentid: Int): List<SubTask> {
        return SubTasks.select(SubTasks.parentid eq  parentid)
                .map {
                    SubTask(it[SubTasks.id].value, it[SubTasks.name], it[SubTasks.isdone], parentid)
                }
    }

    fun findOne(id: Int): SubTask? {
        return SubTasks.select(SubTasks.id eq id)
                .firstOrNull()
                ?.let {
                    SubTask(id, it[SubTasks.name], it[SubTasks.isdone], it[SubTasks.parentid].value)
                }
    }

    fun insertOne(request: PostSubTaskRequest): SubTask {
        mustExistIn(request.parentid, Tasks)

        val id = SubTasks.insert {
            it[parentid] = request.parentid
            it[name] = request.name
        } get SubTasks.id

        return findOne(id.value)!!
    }

    fun deleteOne(id: Int) {
        SubTasks.deleteWhere {
            SubTasks.id eq id
        }
    }

    fun deleteAll(taskid: Int) {
        SubTasks.deleteWhere {
            parentid eq taskid
        }
    }

    fun updateOne(request: UpdateSubTaskRequest): SubTask {
        SubTasks.update({ SubTasks.id eq request.id }) {
            if (request.name != null) {
                it[name] = request.name
            }

            if (request.isdone != null) {
                it[isdone] = request.isdone
            }
        }

        return findOne(request.id) ?: throw BadRequestException("no such subtask")
    }
}