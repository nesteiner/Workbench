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
                    Tag(it[Tags.id].value, it[Tags.name], it[Tags.parentid].value, it[Tags.color])
                }


        return if (iftag != null) {
            iftag
        } else {
            val id = Tags.insert {
                it[name] = request.name
                it[parentid] = request.parentid
                it[color] = request.color
            } get Tags.id

            Tag(id.value, request.name, request.parentid, request.color)
        }
    }

    fun deleteAll(projectid: Int) {
        Tags.deleteWhere {
            parentid eq projectid
        }
    }

    fun updateOne(request: UpdateTagRequest): Tag {
        val ifexist = Tags.select(Tags.name eq request.name).firstOrNull()

        if (ifexist == null) {
            Tags.update({ Tags.id eq request.id }) {
                it[name] = request.name
            }

            return findOne(request.id)!!
        } else {
            throw BadRequestException("there is already a tag named ${request.name}")
        }
    }

    fun findAllOfTask(taskid: Int): List<Tag> {
        return TaskTag.select(TaskTag.taskid eq taskid).map {
            val id = it[TaskTag.tagid]
            Tags.select(Tags.id eq id).first().let {
                Tag(id.value, it[Tags.name], it[Tags.parentid].value, it[Tags.color])
            }
        }
    }

    fun findAllOfProject(projectid: Int): List<Tag> {
        return Tags.select(Tags.parentid eq projectid).map {
            Tag(it[Tags.id].value, it[Tags.name], it[Tags.parentid].value, it[Tags.color])
        }
    }

    fun findOne(id: Int): Tag? {
        return Tags.select(Tags.id eq id)
                .firstOrNull()
                ?.let {
                    Tag(id, it[Tags.name], it[Tags.parentid].value, it[Tags.color])
                }
    }
}