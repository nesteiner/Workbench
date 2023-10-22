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
        return SubTasks.select(SubTasks.parentid eq parentid)
                .orderBy(SubTasks.index)
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
            it[isdone] = false
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
            val (parentid, currentIndex) = SubTasks.slice(SubTasks.parentid, SubTasks.index).select(SubTasks.id eq request.id).first().let {
                listOf(it[SubTasks.parentid].value, it[SubTasks.index])
            }

            if (currentIndex < request.reorderAt) {
                SubTasks.update(
                        {
                            (SubTasks.parentid eq parentid) and (SubTasks.index lessEq request.reorderAt) and (SubTasks.index greater currentIndex)
                        }) {
                    with (SqlExpressionBuilder) {
                        it.update(index, index - 1)
                    }
                }
            } else if (currentIndex > request.reorderAt) {
                SubTasks.update(
                        {
                            (SubTasks.parentid eq parentid) and (SubTasks.index greaterEq request.reorderAt) and (SubTasks.index less currentIndex)
                        }) {
                    with(SqlExpressionBuilder) {
                        it.update(index, index + 1)
                    }
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

            if (request.reorderAt != null) {
                it[index] = request.reorderAt
            }
        }

        return findOne(request.id) ?: throw BadRequestException("no such subtask")
    }
}