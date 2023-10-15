package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.todolist.model.SubTask
import com.steiner.workbench.todolist.request.PostSubTaskRequest
import com.steiner.workbench.todolist.request.UpdateSubTaskRequest
import com.steiner.workbench.todolist.table.SubTasks
import com.steiner.workbench.todolist.table.Tasks
import com.steiner.workbench.todolist.util.mustExistIn
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional


@Service
@Transactional
class SubTaskService {
    fun findAll(parentid: Int): List<SubTask> {
        return SubTasks.select(SubTasks.parentid eq  parentid)
                .map {
                    SubTask(
                            id = it[SubTasks.id].value,
                            name = it[SubTasks.name],
                            index = it[SubTasks.index],
                            isdone = it[SubTasks.isdone],
                            parentid = it[SubTasks.parentid].value
                    )
                }
    }

    fun findOne(id: Int): SubTask? {
        return SubTasks.select(SubTasks.id eq id)
                .firstOrNull()
                ?.let {
                    SubTask(
                            id = id,
                            name = it[SubTasks.name],
                            index = it[SubTasks.index],
                            isdone = it[SubTasks.isdone],
                            parentid = it[SubTasks.parentid].value
                    )
                }
    }

    fun insertOne(request: PostSubTaskRequest): SubTask {
        mustExistIn(request.parentid, Tasks)

        SubTasks.update({ SubTasks.parentid eq request.parentid }) {
            with (SqlExpressionBuilder) {
                it.update(index, index + 1)
            }
        }

        val id = SubTasks.insert {
            it[index] = 1
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
        mustExistIn(request.id, SubTasks)

        if (request.reorderAt != null) {
            val parentid = SubTasks.slice(SubTasks.parentid).select(SubTasks.id eq request.id).first().let {
                it[SubTasks.parentid]
            }

            SubTasks.update({ (SubTasks.parentid eq parentid) and (SubTasks.index greaterEq request.reorderAt) }) {
                with (SqlExpressionBuilder) {
                    it.update(index, index + 1)
                }
            }
        }

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