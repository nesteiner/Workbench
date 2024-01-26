package com.steiner.workbench.app.plugin

import com.steiner.workbench.login.request.PostAdminRequest
import com.steiner.workbench.login.request.PostRoleRequest
import com.steiner.workbench.login.request.PostUserRequest
import com.steiner.workbench.login.service.RoleService
import com.steiner.workbench.login.service.UserService
import io.ktor.server.application.*
import kotlinx.coroutines.runBlocking
import com.steiner.workbench.common.`role-admin`
import com.steiner.workbench.common.`role-default`
import com.steiner.workbench.todolist.service.*
import org.koin.ktor.ext.inject

fun Application.configureInitialize() {
    val config = environment.config
    val isInitialize = config.property("app.initialize").getString().toBoolean()
    val userService: UserService by inject<UserService>()
    val roleService: RoleService by inject<RoleService>()
    val priorityService: PriorityService by inject<PriorityService>()
    val tagService: TagService by inject<TagService>()
    val taskProjectService: TaskProjectService by inject<TaskProjectService>()
    val taskGroupService: TaskGroupService by inject<TaskGroupService>()
    val taskService: TaskService by inject<TaskService>()

    if (!isInitialize) {
        return
    }

    runBlocking {
        userService.clear()
        roleService.clear()
        priorityService.clear()
        tagService.clear()
        taskProjectService.clear()
        taskGroupService.clear()
        taskService.clear()

        arrayOf(
            PostRoleRequest(`role-admin`),
            PostRoleRequest(`role-default`)
        ).forEach {
            roleService.insertOne(it)
        }

        arrayOf(
            PostUserRequest(
                username = "steiner",
                email = "steiner3044@163.com",
                enabled = true,
                passwordHash = "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8",
                passwordLength = 8
            )
        ).forEach {
            userService.insertOne(it)
        }

        userService.insertAdmin(PostAdminRequest(
            username = "admin",
            email = "steiner3044@163.com",
            enabled = true,
            passwordHash = "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8"
        ))
    }
}