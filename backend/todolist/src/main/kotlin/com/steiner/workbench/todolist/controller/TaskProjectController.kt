package com.steiner.workbench.todolist.controller

import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.common.util.Page
import com.steiner.workbench.common.util.Response
import com.steiner.workbench.login.service.UserService
import com.steiner.workbench.todolist.model.TaskProject
import com.steiner.workbench.todolist.request.PostTaskProjectRequest
import com.steiner.workbench.todolist.request.UpdateTaskProjectRequest
import com.steiner.workbench.todolist.service.TaskProjectService
import com.steiner.workbench.websocket.endpoint.WebSocketEndpoint
import com.steiner.workbench.websocket.model.Operation
import jakarta.validation.Valid
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.core.context.SecurityContextHolder
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
@RequestMapping("/{uid}/todolist/taskproject")
@Validated
class TaskProjectController {
    @Autowired
    lateinit var taskprojectService: TaskProjectService
    @Autowired
    lateinit var userService: UserService

    @PostMapping
    fun insertOne(@RequestBody @Valid request: PostTaskProjectRequest, bindingResult: BindingResult, @PathVariable("uid") uid: String): Response<TaskProject> {
        val result = taskprojectService.insertOne(request)
        WebSocketEndpoint.notifyAll(uid, Operation.TaskProjectPost)
        return Response.Ok("insert ok", result)
    }

    @DeleteMapping("/{id}")
    fun deleteOne(@PathVariable("id") id: Int, @PathVariable("uid") uid: String): Response<Unit> {
        taskprojectService.deleteOne(id)
        WebSocketEndpoint.notifyAll(uid, Operation.TaskProjectDelete(id))
        return Response.Ok("delete ok", Unit)
    }

    @PutMapping
    fun updateOne(@RequestBody @Valid request: UpdateTaskProjectRequest, bindingResult: BindingResult, @PathVariable("uid") uid: String): Response<TaskProject> {
        val result = taskprojectService.updateOne(request)
        WebSocketEndpoint.notifyAll(uid, Operation.TaskProjectUpdate(request.id))
        return Response.Ok("update ok", result)
    }

    @GetMapping
    fun findAll(): Response<List<TaskProject>> {
        val userid = userService.currentUserId()
        val result = taskprojectService.findAll(userid)
        return Response.Ok("all task projects", result)
    }

    @GetMapping(params = ["page", "size"])
    fun findAll(@RequestParam("page") page: Int, @RequestParam("size") size: Int): Response<Page<TaskProject>> {
        val userdetail = SecurityContextHolder.getContext().authentication
        val username = userdetail.name
        val userid = userService.findOne(username)!!.id

        return Response.Ok("all task projects", taskprojectService.findAll(userid, page, size))
    }

    @GetMapping("/{id}")
    fun findOne(@PathVariable("id") id: Int): Response<TaskProject> {
        val iftaskproject = taskprojectService.findOne(id) ?: throw BadRequestException("no such task project")
        return Response.Ok("this task project", iftaskproject)
    }
}