package com.steiner.workbench.todolist.controller

import com.steiner.workbench.common.util.Response
import com.steiner.workbench.todolist.model.Task
import com.steiner.workbench.todolist.request.PostTaskRequest
import com.steiner.workbench.todolist.request.PostTaskTagRequest
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
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/todolist/task")
@Validated
class TaskController {
    @Autowired
    lateinit var taskService: TaskService
    @PostMapping
    fun insertOne(@RequestBody @Valid request: PostTaskRequest, bindingResult: BindingResult): Response<Task> {
        return Response.Ok("insert ok", taskService.insertOne(request))
    }

    @PostMapping("/tag")
    fun insertTag(@RequestBody request: PostTaskTagRequest): Response<Unit> {
        taskService.insertTag(request)
        return Response.Ok("insert tag ok", Unit)
    }

    @DeleteMapping("/{id}")
    fun deleteOne(@PathVariable("id") id: Int): Response<Unit> {
        taskService.deleteOne(id)
        return Response.Ok("delete ok", Unit)
    }

    @DeleteMapping("/deadline/{id}")
    fun removeDeadline(@PathVariable("id") id: Int): Response<Unit> {
        taskService.removeDeadline(id)
        return Response.Ok("remove deadline ok", Unit)
    }

    @DeleteMapping("/tag", params = ["taskid", "tagid"])
    fun removeTag(@RequestParam("taskid") taskid: Int, @RequestParam("tagid") tagid: Int): Response<Unit> {
        taskService.removeTag(taskid, tagid)
        return Response.Ok("remove tag ok", Unit)
    }

    @DeleteMapping("/notifyTime/{id}")
    fun removeNotifyTime(@PathVariable("id") id: Int): Response<Unit> {
        taskService.removeNotifyTime(id)
        return Response.Ok("remove notify time ok", Unit)
    }

    @PutMapping
    fun updateOne(@RequestBody @Valid request: UpdateTaskRequest, bindingResult: BindingResult): Response<Task> {
        return Response.Ok("update ok", taskService.updateOne(request))
    }
}