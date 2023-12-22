package com.steiner.workbench.todolist.controller

import com.steiner.workbench.common.util.Response
import com.steiner.workbench.todolist.model.Tag
import com.steiner.workbench.todolist.request.PostTagRequest
import com.steiner.workbench.todolist.request.UpdateTagRequest
import com.steiner.workbench.todolist.service.TagService
import jakarta.validation.Valid
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.validation.BindingResult
import org.springframework.validation.annotation.Validated
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/{uid}/todolist/tag")
@Validated
class TagController {
    @Autowired
    lateinit var tagService: TagService
    @PostMapping
    fun insertOne(@RequestBody @Valid request: PostTagRequest, bindingResult: BindingResult): Response<Tag> {
        return Response.Ok("insert ok", tagService.insertOne(request))
    }

    @PutMapping
    fun updateOne(@RequestBody @Valid request: UpdateTagRequest, bindingResult: BindingResult): Response<Tag> {
        return Response.Ok("update ok", tagService.updateOne(request))
    }

    @GetMapping(params = ["projectid"])
    fun findAll(@RequestParam("projectid") projectid: Int): Response<List<Tag>> {
        return Response.Ok("all tags", tagService.findAllOfProject(projectid))
    }
}