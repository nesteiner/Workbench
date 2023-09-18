package com.steiner.workbench.login.controller

import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.common.util.Page
import com.steiner.workbench.common.util.Response
import com.steiner.workbench.login.model.Role
import com.steiner.workbench.login.request.PostRoleRequest
import com.steiner.workbench.login.request.UpdateRoleRequest
import com.steiner.workbench.login.service.RoleService
import jakarta.validation.Valid
import org.springframework.beans.factory.annotation.Autowired
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
@RequestMapping("/admin/role")
@Validated
class RoleController {
    @Autowired
    lateinit var roleService: RoleService

    @GetMapping("/{id}")
    fun findOne(@PathVariable id: Int): Response<Role> {
        val role = roleService.findOne(id)
        return if (role == null) {
            throw BadRequestException("no such role with id: $id")
        } else {
            Response.Ok("this role", role)
        }
    }

    @GetMapping
    fun findAll(): Response<List<Role>> {
        return Response.Ok("all roles", roleService.findAll())
    }

    @GetMapping(params = ["page", "size"])
    fun findAll(@RequestParam("page") page: Int, @RequestParam("size") size: Int): Response<Page<Role>> {
        return Response.Ok("all roles", roleService.findAll(page, size))
    }

    @PostMapping
    fun insertOne(@RequestBody @Valid request: PostRoleRequest, result: BindingResult): Response<Role> {
        return Response.Ok("insert ok", roleService.insertOne(request))
    }

    @PutMapping
    fun updateOne(@RequestBody @Valid request: UpdateRoleRequest, result: BindingResult): Response<Role> {
        return Response.Ok("update ok", roleService.updateOne(request))
    }
}