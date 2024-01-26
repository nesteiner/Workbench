package com.steiner.workbench.login

import com.steiner.workbench.common.util.SimpleJWT
import com.steiner.workbench.login.exception.AuthenticationException
import com.steiner.workbench.login.principal.IdPrincipal
import com.steiner.workbench.login.request.LoginRequest
import com.steiner.workbench.login.request.PostUserRequest
import com.steiner.workbench.login.request.UpdateUserRequest
import com.steiner.workbench.login.service.UserService
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import com.steiner.workbench.common.`normal-jwt`
import com.steiner.workbench.common.util.Response
import org.koin.ktor.ext.inject

fun Application.routingLogin() {
    val userService: UserService by inject<UserService>()
    val simpleJWT: SimpleJWT by inject<SimpleJWT>()

    routing {
        post("/authenticate") {
            val request = call.receive<LoginRequest>()
            val user = userService.login(request)

            call.respond(Response.Ok("login ok", mapOf(
                "token" to simpleJWT.sign(user.id, user.name)
            )))
        }

        post("/register") {
            val request = call.receive<PostUserRequest>()
            val user = userService.insertOne(request)

            call.respond(Response.Ok("register ok", user))
        }

        authenticate(`normal-jwt`) {
            get("/user") {
                val principal = call.principal<IdPrincipal>()!!
                val user = userService.findOne(principal.id) ?: throw AuthenticationException("no such user")
                call.respond(Response.Ok("this user", user))
            }

            put("/user") {
                val request = call.receive<UpdateUserRequest>()
                val user = userService.updateOne(request)
                call.respond(Response.Ok("update ok", user))
            }
        }
    }
}