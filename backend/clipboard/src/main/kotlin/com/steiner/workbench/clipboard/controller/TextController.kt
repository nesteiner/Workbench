package com.steiner.workbench.clipboard.controller

import com.steiner.workbench.clipboard.model.Text
import com.steiner.workbench.clipboard.request.PostTextRequest
import com.steiner.workbench.clipboard.service.TextService
import com.steiner.workbench.common.util.Page
import com.steiner.workbench.common.util.Response
import com.steiner.workbench.login.service.UserService
import jakarta.validation.Valid
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.validation.BindingResult
import org.springframework.validation.annotation.Validated
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@Validated
@RequestMapping("/clipboard")
/// ATTENTION, consider there is no @Serializable in Text, there is no need to use `Response.Ok`
class TextController {
    @Autowired
    lateinit var textService: TextService
    @Autowired
    lateinit var userService: UserService

    val userid: Int
        get() = userService.currentUserId()

    @PostMapping
    fun insertOne(@RequestBody @Valid request: PostTextRequest, bindingResult: BindingResult): Response<Text> {
        return Response.Ok("insert ok", textService.insertOne(request))
    }

    @DeleteMapping("/{id}")
    fun deleteOne(@PathVariable("id") id: Int): Response<Unit> {
        textService.deleteOne(id)
        return Response.Ok("delete ok", Unit)
    }


    @GetMapping(params = ["page", "size"])
    fun findAll(@RequestParam("page") page: Int, @RequestParam("size") size: Int): Response<Page<Text>> {
        return Response.Ok("all texts", textService.findAll(userid, page, size))
    }

    @GetMapping
    fun findAll(): Response<List<Text>> {
        return Response.Ok("all texts", textService.findAll(userid))
    }

    @GetMapping("/{id}")
    fun findOne(@PathVariable("id") id: Int): Response<Text?> {
        return Response.Ok("this text", textService.findOne(id))
    }
}