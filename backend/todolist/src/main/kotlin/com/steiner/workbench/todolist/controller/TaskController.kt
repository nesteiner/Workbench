package com.steiner.workbench.todolist.controller

import com.steiner.workbench.common.util.Response
import com.steiner.workbench.todolist.model.Task
import com.steiner.workbench.todolist.request.PostTaskRequest
import com.steiner.workbench.todolist.request.UpdateTaskRequest
import com.steiner.workbench.todolist.service.TaskService
import jakarta.validation.Valid
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.validation.BindingResult
import org.springframework.validation.annotation.Validated
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/task")
@Validated
class TaskController {
    @Autowired
    lateinit var taskService: TaskService
    @PostMapping
    fun insertOne(@RequestBody @Valid request: PostTaskRequest, bindingResult: BindingResult): Response<Task> {
        return Response.Ok("insert ok", taskService.insertOne(request))
    }

    @DeleteMapping("/{id}")
    fun deleteOne(@PathVariable("id") id: Int): Response<Unit> {
        taskService.deleteOne(id)
        return Response.Ok("delete ok", Unit)
    }

    @PutMapping
    fun updateOne(@RequestBody @Valid request: UpdateTaskRequest, bindingResult: BindingResult): Response<Task> {
        return Response.Ok("update ok", taskService.updateOne(request))
    }
}