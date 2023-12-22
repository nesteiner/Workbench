package com.steiner.workbench.todolist.controller

import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.common.util.Response
import com.steiner.workbench.todolist.model.Task
import com.steiner.workbench.todolist.request.PostTaskRequest
import com.steiner.workbench.todolist.request.PostTaskTagRequest
import com.steiner.workbench.todolist.request.UpdateTaskRequest
import com.steiner.workbench.todolist.service.TaskGroupService
import com.steiner.workbench.todolist.service.TaskService
import com.steiner.workbench.websocket.endpoint.WebSocketEndpoint
import com.steiner.workbench.websocket.model.Operation
import jakarta.validation.Valid
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.validation.BindingResult
import org.springframework.validation.annotation.Validated
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/{uid}/todolist/task")
@Validated
class TaskController {
    @Autowired
    lateinit var taskService: TaskService
    @Autowired
    lateinit var taskGroupService: TaskGroupService

    @PostMapping
    fun insertOne(@RequestBody @Valid request: PostTaskRequest, bindingResult: BindingResult, @PathVariable("uid") uid: String): Response<Task> {
        val taskgroup = taskGroupService.findOne(request.parentid) ?: throw BadRequestException("no such task group with id ${request.parentid}")
        val result = taskService.insertOne(request)
        WebSocketEndpoint.notifyAll(uid, Operation.TaskPost(taskgroup.parentid, taskgroup.id))

        return Response.Ok("insert ok", result)
    }

    @PostMapping("/tag")
    fun insertTag(@RequestBody request: PostTaskTagRequest, @PathVariable("uid") uid: String): Response<Unit> {
        val task = taskService.findOne(request.taskid) ?: throw BadRequestException("no such task with id ${request.taskid}")
        val taskgroup = taskGroupService.findOne(task.parentid)!!
        taskService.insertTag(request)
        WebSocketEndpoint.notifyAll(uid, Operation.TaskUpdate(taskgroup.parentid, taskgroup.id, task.id))

        return Response.Ok("insert tag ok", Unit)
    }

    @DeleteMapping("/{id}")
    fun deleteOne(@PathVariable("id") id: Int, @PathVariable("uid") uid: String): Response<Unit> {
        val task = taskService.findOne(id) ?: throw BadRequestException("no such task with id $id")
        val taskgroup = taskGroupService.findOne(task.parentid)!!
        taskService.deleteOne(id)
        WebSocketEndpoint.notifyAll(uid, Operation.TaskDelete(taskgroup.parentid, taskgroup.id, task.id))

        return Response.Ok("delete ok", Unit)
    }

    @DeleteMapping("/deadline/{id}")
    fun removeDeadline(@PathVariable("id") id: Int, @PathVariable("uid") uid: String): Response<Unit> {
        val task = taskService.findOne(id) ?: throw BadRequestException("no such task with id $id")
        val taskgroup = taskGroupService.findOne(task.parentid)!!
        taskService.removeDeadline(id)
        WebSocketEndpoint.notifyAll(uid, Operation.TaskUpdate(taskgroup.parentid, taskgroup.id, task.id))

        return Response.Ok("remove deadline ok", Unit)
    }

    @DeleteMapping("/tag", params = ["taskid", "tagid"])
    fun removeTag(@RequestParam("taskid") taskid: Int, @RequestParam("tagid") tagid: Int, @PathVariable("uid") uid: String): Response<Unit> {
        val task = taskService.findOne(taskid) ?: throw BadRequestException("no such task with id $taskid")
        val taskgroup = taskGroupService.findOne(task.parentid)!!
        taskService.removeTag(taskid, tagid)
        WebSocketEndpoint.notifyAll(uid, Operation.TaskUpdate(taskgroup.parentid, taskgroup.id, task.id))

        return Response.Ok("remove tag ok", Unit)
    }

    @DeleteMapping("/notifyTime/{id}")
    fun removeNotifyTime(@PathVariable("id") id: Int, @PathVariable("uid") uid: String): Response<Unit> {
        val task = taskService.findOne(id) ?: throw BadRequestException("no such task with id $id")
        val taskgroup = taskGroupService.findOne(task.parentid)!!
        taskService.removeNotifyTime(id)
        WebSocketEndpoint.notifyAll(uid, Operation.TaskUpdate(taskgroup.parentid, taskgroup.id, task.id))

        return Response.Ok("remove notify time ok", Unit)
    }

    @PutMapping
    fun updateOne(@RequestBody @Valid request: UpdateTaskRequest, bindingResult: BindingResult, @PathVariable("uid") uid: String): Response<Task> {
        val result = taskService.updateOne(request)
        val task = taskService.findOne(request.id) ?: throw BadRequestException("no such task with id ${request.id}")
        val taskgroup = taskGroupService.findOne(task.parentid)!!
        WebSocketEndpoint.notifyAll(uid, Operation.TaskUpdate(taskgroup.parentid, taskgroup.id, task.id))

        return Response.Ok("update ok", result)
    }

    @GetMapping("/{id}")
    fun findOne(@PathVariable("id") id: Int): Response<Task> {
        val result = taskService.findOne(id) ?: throw BadRequestException("no such task with id $id")
        return Response.Ok("this task", result)
    }
}