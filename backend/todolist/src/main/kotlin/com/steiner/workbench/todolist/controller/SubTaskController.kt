package com.steiner.workbench.todolist.controller

import com.steiner.workbench.common.util.Response
import com.steiner.workbench.todolist.model.SubTask
import com.steiner.workbench.todolist.request.PostSubTaskRequest
import com.steiner.workbench.todolist.request.UpdateSubTaskRequest
import com.steiner.workbench.todolist.service.SubTaskService
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
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/todolist/subtask")
@Validated
class SubTaskController {
    @Autowired
    lateinit var subtaskService: SubTaskService
    @PostMapping
    fun insertOne(@RequestBody @Valid request: PostSubTaskRequest, bindingResult: BindingResult): Response<SubTask> {
        return Response.Ok("insert ok", subtaskService.insertOne(request))
    }

    @DeleteMapping("/{id}")
    fun deleteOne(@PathVariable("id") id: Int): Response<Unit> {
        subtaskService.deleteOne(id)
        return Response.Ok("delete ok", Unit)
    }

    @PutMapping
    fun updateOne(@RequestBody @Valid request: UpdateSubTaskRequest, bindingResult: BindingResult): Response<SubTask> {
        return Response.Ok("update ok", subtaskService.updateOne(request))
    }
}