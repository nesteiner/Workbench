package com.steiner.workbench.todolist.controller

import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.common.util.Response
import com.steiner.workbench.todolist.model.TaskGroup
import com.steiner.workbench.todolist.request.PostTaskGroupRequest
import com.steiner.workbench.todolist.request.UpdateTaskGroupRequest
import com.steiner.workbench.todolist.service.TaskGroupService
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
@RequestMapping("/{uid}/todolist/taskgroup")
@Validated
class TaskGroupController {
    @Autowired
    lateinit var taskgroupService: TaskGroupService

    @PostMapping
    fun insertOne(@RequestBody @Valid request: PostTaskGroupRequest, @PathVariable("uid") uid: String, bindingResult: BindingResult,): Response<TaskGroup> {
        val result = taskgroupService.insertOne(request)
        WebSocketEndpoint.notifyAll(uid, Operation.TaskGroupPost(taskprojectId = request.parentid))
        return Response.Ok("insert ok", result)
    }

    @PostMapping(params = ["after"])
    fun insertOne(@RequestBody @Valid request: PostTaskGroupRequest, @RequestParam("after") after: Int, bindingResult: BindingResult, @PathVariable("uid") uid: String): Response<TaskGroup> {
        val result = taskgroupService.insertOne(request, after)
        WebSocketEndpoint.notifyAll(uid, Operation.TaskGroupPost(taskprojectId = request.parentid))
        return Response.Ok("insert ok", result)
    }

    @DeleteMapping("/{id}")
    fun deleteOne(@PathVariable("id") id: Int, @PathVariable("uid") uid: String): Response<Unit> {
        val item = taskgroupService.findOne(id) ?: throw BadRequestException("no such taskgroup with id $id")
        taskgroupService.deleteOne(id)
        WebSocketEndpoint.notifyAll(uid, Operation.TaskGroupDelete(item.parentid, item.id))
        return Response.Ok("delete ok", Unit)
    }

    @PutMapping
    fun updateOne(@RequestBody @Valid request: UpdateTaskGroupRequest, bindingResult: BindingResult, @PathVariable("uid") uid: String): Response<TaskGroup> {
        val result = taskgroupService.updateOne(request)
        WebSocketEndpoint.notifyAll(uid, Operation.TaskGroupUpdate(result.parentid, result.id))
        return Response.Ok("update ok", result)
    }

    @GetMapping(params = ["projectid"])
    fun findAll(@RequestParam("projectid") projectid: Int): Response<List<TaskGroup>> {
        return Response.Ok("all taskgroup", taskgroupService.findAll(projectid))
    }

    @GetMapping("/{id}")
    fun findOne(@PathVariable("id") id: Int): Response<TaskGroup> {
        val result = taskgroupService.findOne(id) ?: throw BadRequestException("no such taskgroup with id $id")
        return Response.Ok("this taskgroup", result)
    }
}