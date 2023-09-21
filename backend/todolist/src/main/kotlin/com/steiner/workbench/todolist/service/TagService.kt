package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.todolist.model.Tag
import com.steiner.workbench.todolist.request.PostTagRequest
import com.steiner.workbench.todolist.request.UpdateTagRequest
import com.steiner.workbench.todolist.table.Tags
import com.steiner.workbench.todolist.table.TaskProjects
import com.steiner.workbench.todolist.table.TaskTag
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
class TagService {
    fun insertOne(request: PostTagRequest): Tag {
        mustExistIn(request.parentid, TaskProjects)

        val iftag = Tags.select(Tags.name eq request.name)
                .firstOrNull()?.let {
                    Tag(it[Tags.id].value, it[Tags.name], it[Tags.parentid].value)
                }


        return if (iftag != null) {
            iftag
        } else {
            val id = Tags.insert {
                it[name] = request.name
                it[parentid] = request.parentid
            } get Tags.id

            Tag(id.value, request.name, request.parentid)
        }
    }

    fun deleteAll(projectid: Int) {
        Tags.deleteWhere {
            parentid eq projectid
        }
    }

    fun updateOne(request: UpdateTagRequest): Tag {
        Tags.update({Tags.id eq request.id}) {
            it[name] = request.name
        }

        return findOne(request.id) ?: throw BadRequestException("no such tag")
    }

    fun findAllOfTask(taskid: Int): List<Tag> {
        return TaskTag.select(TaskTag.taskid eq taskid).map {
            val id = it[TaskTag.tagid]
            Tags.slice(Tags.name, Tags.parentid).select(Tags.id eq id).first().let {
                Tag(id.value, it[Tags.name], it[Tags.parentid].value)
            }
        }
    }

    fun findAllOfProject(projectid: Int): List<Tag> {
        return Tags.select(Tags.parentid eq projectid).map {
            Tag(it[Tags.id].value, it[Tags.name], it[Tags.parentid].value)
        }
    }

    fun findOne(id: Int): Tag? {
        return Tags.select(Tags.id eq id)
                .firstOrNull()
                ?.let {
                    Tag(id, it[Tags.name], it[Tags.parentid].value)
                }
    }
}