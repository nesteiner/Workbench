package com.steiner.workbench.login.controller

import com.steiner.workbench.common.ROLE_ADMIN
import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.common.util.Page
import com.steiner.workbench.common.util.Response
import com.steiner.workbench.login.exception.PermissionDeniedException
import com.steiner.workbench.login.model.User
import com.steiner.workbench.login.request.PostUserRequest
import com.steiner.workbench.login.request.UpdateUserRequest
import com.steiner.workbench.login.service.UserService
import jakarta.validation.Valid
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.validation.BindingResult
import org.springframework.validation.annotation.Validated
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/user")
@Validated
class UserController {
    @Autowired
    lateinit var userService: UserService

    @PostMapping("/register")
    fun insertOne(@RequestBody @Valid request: PostUserRequest, bindingResult: BindingResult): Response<User> {
        val requestAdmin = request.roles.any {
            it.name == ROLE_ADMIN
        }

        if (requestAdmin) {
            throw PermissionDeniedException("you have no such permission to create a admin")
        } else {
            return Response.Ok("insert ok", userService.insertOne(request))
        }
    }

    @PutMapping
    fun updateOne(@RequestBody @Valid request: UpdateUserRequest, bindingResult: BindingResult): Response<User> {
        val userdetail = SecurityContextHolder.getContext().authentication
        val username = userdetail.name

        val currentUser = userService.findOne(username)!!
        val userid = currentUser.id

        return Response.Ok("update ok", userService.updateOne(request, userid))
    }

    @GetMapping(params = ["page", "size"])
    fun findAll(@RequestParam("page") page: Int, @RequestParam("size") size: Int): Response<Page<User>> {
        return Response.Ok("all users", userService.findAll(page, size))
    }

    @GetMapping
    fun findAll(): Response<List<User>> {
        return Response.Ok("all users", userService.findAll())
    }

    @GetMapping(params = ["id"])
    fun findOne(@RequestParam("id") id: Int): Response<User> {
        val user = userService.findOne(id)
        return if (user == null) {
            throw BadRequestException("no such user")
        } else {
            Response.Ok("this user", user)
        }
    }

    @GetMapping(params = ["name"])
    fun findOne(@RequestParam("name") name: String): Response<User> {
        val user = userService.findOne(name)
        return if (user == null) {
            throw BadRequestException("no such user")
        } else {
            Response.Ok("this user", user)
        }
    }
}