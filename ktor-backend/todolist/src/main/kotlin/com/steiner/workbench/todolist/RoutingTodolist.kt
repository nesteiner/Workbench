package com.steiner.workbench.todolist

import com.steiner.workbench.common.`normal-jwt`
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import com.steiner.workbench.common.util.Response
import com.steiner.workbench.login.principal.IdPrincipal
import com.steiner.workbench.login.service.UserService
import com.steiner.workbench.todolist.request.*
import com.steiner.workbench.todolist.service.*
import io.ktor.server.auth.*
import io.ktor.server.plugins.*
import org.koin.ktor.ext.inject

fun Application.routingTodolist() {
    val tagService: TagService by inject<TagService>()
    val subTaskService: SubTaskService by inject<SubTaskService>()
    val taskService: TaskService by inject<TaskService>()
    val taskGroupService: TaskGroupService by inject<TaskGroupService>()
    val taskProjectService: TaskProjectService by inject<TaskProjectService>()

    routing {
        authenticate(`normal-jwt`) {
            route("/todolist/tag") {
                post {
                    val request = call.receive<PostTagRequest>()
                    call.respond(Response.Ok("insert ok", tagService.insertOne(request)))
                }

                put {
                    val request = call.receive<UpdateTagRequest>()
                    call.respond(Response.Ok("update ok", tagService.updateOne(request)))
                }

                get {
                    val projectid = call.request.queryParameters["projectid"]?.toIntOrNull()
                        ?: throw NotFoundException("expected project id")
                    call.respond(Response.Ok("all tags", tagService.findAllOfTask(projectid)))
                }
            }

            route("/todolist/subtask") {
                post {
                    val request = call.receive<PostSubTaskRequest>()
                    call.respond(Response.Ok("insert ok", subTaskService.insertOne(request)))
                }

                delete("/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    subTaskService.deleteOne(id)
                    call.respond(Response.Ok("delete ok", Unit))
                }

                put {
                    val request = call.receive<UpdateSubTaskRequest>()
                    call.respond(Response.Ok("update ok", subTaskService.updateOne(request)))
                }
            }

            route("/todolist/task") {
                post {
                    val request = call.receive<PostTaskRequest>()
                    val taskgroup = taskGroupService.findOne(request.parentid)
                        ?: throw NotFoundException("no such task group with id ${request.parentid}")
                    val result = taskService.insertOne(request)

                    call.respond(Response.Ok("insert ok", result))
                }

                post("/tag") {
                    val request = call.receive<PostTaskTagRequest>()
                    val task = taskService.findOne(request.taskid)
                        ?: throw NotFoundException("no such task with id ${request.taskid}")
                    val taskgroup = taskGroupService.findOne(task.parentid)
                        ?: throw NotFoundException("no such task group with id ${task.parentid}")
                    taskService.insertTag(request)

                    call.respond(Response.Ok("insert tag ok", Unit))
                }

                delete("/{id}") {
                    val id = call.request.queryParameters["id"]?.toIntOrNull() ?: throw NotFoundException("expect id")
                    val task = taskService.findOne(id) ?: throw NotFoundException("no such task with id $id")
                    val taskgroup = taskGroupService.findOne(task.parentid)
                        ?: throw NotFoundException("no such taskgroup with id ${task.parentid}")
                    taskService.deleteOne(id)
                    call.respond(Response.Ok("delete ok", Unit))
                }

                delete("/deadline/{id}") {
                    val id = call.request.queryParameters["id"]?.toIntOrNull() ?: throw NotFoundException("expect id")
                    val task = taskService.findOne(id) ?: throw NotFoundException("no such task with id $id")
                    val taskgroup = taskGroupService.findOne(task.parentid)
                        ?: throw NotFoundException("no such task group with id ${task.parentid}")
                    taskService.removeDeadline(id)

                    call.respond(Response.Ok("remove deadline ok", Unit))
                }

                delete("/tag") {
                    val taskid = call.request.queryParameters["taskid"]?.toIntOrNull()
                        ?: throw NotFoundException("expect taskid")
                    val tagid = call.request.queryParameters["tagid"]?.toIntOrNull()
                        ?: throw NotFoundException("expect tagid")
                    val task = taskService.findOne(taskid) ?: throw NotFoundException("no such task with id $taskid")
                    val taskgroup = taskGroupService.findOne(task.parentid)
                        ?: throw NotFoundException("no such task group with id ${task.parentid}")
                    taskService.removeTag(taskid, tagid)

                    call.respond(Response.Ok("remove tag ok", Unit))
                }

                delete("/notify-time/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    val task = taskService.findOne(id) ?: throw NotFoundException("no such task with id $id")
                    val taskgroup = taskGroupService.findOne(task.parentid)
                        ?: throw NotFoundException("no such task group with id ${task.parentid}")
                    taskService.removeNotifyTime(id)

                    call.respond(Response.Ok("remove notify time ok", Unit))
                }

                put {
                    val request = call.receive<UpdateTaskRequest>()
                    val result = taskService.updateTask(request)
                    val task = taskService.findOne(request.id)
                        ?: throw NotFoundException("no such task with id ${request.id}")
                    val taskgroup = taskGroupService.findOne(task.parentid)
                        ?: throw NotFoundException("no such task group with id ${task.parentid}")

                    call.respond(Response.Ok("update ok", result))
                }

                get("/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    val result = taskService.findOne(id) ?: throw NotFoundException("no such task with id $id")
                    call.respond(Response.Ok("this task", result))
                }

            }

            route("/todolist/taskgroup") {
                post {
                    val after = call.request.queryParameters["after"]?.toIntOrNull()
                    val request = call.receive<PostTaskGroupRequest>()

                    val result = if (after == null) {
                        taskGroupService.insertOne(request)
                    } else {
                        taskGroupService.insertOne(request, after)
                    }

                    call.respond(Response.Ok("insert ok", result))
                }

                delete("/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    val taskGroup = taskGroupService.findOne(id) ?: throw NotFoundException("no such task group with id $id")
                    taskGroupService.deleteOne(id)

                    call.respond(Response.Ok("delete ok", Unit))
                }

                put {
                    val request = call.receive<UpdateTaskGroupRequest>()
                    val result = taskGroupService.updateOne(request)

                    call.respond(Response.Ok("update ok", result))
                }

                get {
                    val parentid = call.request.queryParameters["parentid"]?.toIntOrNull() ?: throw NotFoundException("expect parentid")
                    call.respond(Response.Ok("all taskgroup", taskGroupService.findAll(parentid)))
                }

                get("/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    val result = taskGroupService.findOne(id) ?: throw NotFoundException("no such task group with id $id")
                    call.respond(Response.Ok("this taskgroup", result))
                }

            }

            route("/todolist/taskproject") {
                post {
                    val request = call.receive<PostTaskProjectRequest>()
                    val result = taskProjectService.insertOne(request)

                    call.respond(Response.Ok("insert ok", result))
                }

                delete("/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    taskProjectService.deleteOne(id)

                    call.respond(Response.Ok("delete ok", Unit))
                }

                put {
                    val request = call.receive<UpdateTaskProjectRequest>()
                    val result = taskProjectService.updateOne(request)

                    call.respond(Response.Ok("update ok", result))
                }

                get {
                    val principal = call.principal<IdPrincipal>()!!
                    val userid = principal.id
                    val result = taskProjectService.findAll(userid)

                    call.respond(Response.Ok("all task projects", result))
                }

                get("/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    val result = taskProjectService.findOne(id) ?: throw NotFoundException("no such task project with id $id")
                    call.respond(Response.Ok("this task project", result))
                }
            }
        }
    }
}