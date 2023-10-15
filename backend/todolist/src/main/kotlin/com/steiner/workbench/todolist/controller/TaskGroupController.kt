package com.steiner.workbench.todolist.controller

import com.steiner.workbench.common.util.Response
import com.steiner.workbench.todolist.model.TaskGroup
import com.steiner.workbench.todolist.request.PostTaskGroupRequest
import com.steiner.workbench.todolist.request.UpdateTaskGroupRequest
import com.steiner.workbench.todolist.service.TaskGroupService
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
@RequestMapping("/todolist/taskgroup")
@Validated
class TaskGroupController {
    @Autowired
    lateinit var taskgroupService: TaskGroupService

    @PostMapping
    fun insertOne(@RequestBody @Valid request: PostTaskGroupRequest, bindingResult: BindingResult): Response<TaskGroup> {
        return Response.Ok("insert ok", taskgroupService.insertOne(request))
    }

    @PostMapping(params = ["after"])
    fun insertOne(@RequestBody @Valid request: PostTaskGroupRequest, @RequestParam("after") after: Int, bindingResult: BindingResult): Response<TaskGroup> {
        return Response.Ok("insert ok", taskgroupService.insertOne(request, after))
    }

    @DeleteMapping("/{id}")
    fun deleteOne(@PathVariable("id") id: Int): Response<Unit> {
        taskgroupService.deleteOne(id)
        return Response.Ok("delete ok", Unit)
    }

    @PutMapping
    fun updateOne(@RequestBody @Valid request: UpdateTaskGroupRequest, bindingResult: BindingResult): Response<TaskGroup> {
        return Response.Ok("update ok", taskgroupService.updateOne(request))
    }

    @GetMapping(params = ["projectid"])
    fun findAll(@RequestParam("projectid") projectid: Int): Response<List<TaskGroup>> {
        return Response.Ok("all taskgroup", taskgroupService.findAll(projectid))
    }


}