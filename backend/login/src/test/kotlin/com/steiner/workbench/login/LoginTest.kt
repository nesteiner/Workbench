package com.steiner.workbench.login

import com.steiner.workbench.login.model.Role
import com.steiner.workbench.login.request.PostUserRequest
import com.steiner.workbench.login.service.RoleService
import com.steiner.workbench.login.service.UserService
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest(classes = [com.steiner.workbench.Application::class])
class LoginTest {
    @Autowired
    lateinit var userService: UserService
    @Autowired
    lateinit var roleService: RoleService

    @Test
    fun injectFakeData() {
        val roles = listOf(
                Role(id = 1, name = "admin"),
                Role(id = 2, name = "user")
        )

        userService.insertOne(PostUserRequest(
                name = "steiner",
                passwordHash = "5f4dcc3b5aa765d61d8327deb882cf99",
                roles = listOf(roles[0]),
                enabled = true,
                email = "steiner3044@163.com"
        ))
    }
}