package com.steiner.workbench.app.plugin

import com.steiner.workbench.login.exception.AuthenticationException
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.plugins.*
import io.ktor.server.plugins.statuspages.*
import io.ktor.server.response.*
import com.steiner.workbench.common.util.Response

fun Application.configureErrorHandler() {
    install(StatusPages) {
        exception<AuthenticationException> { call, cause ->
            call.respond(HttpStatusCode.Unauthorized, Response.Err("error when authenticate: ${cause.message}"))
        }

        /// this is for debugging in the frontend
        exception<BadRequestException> { call, cause ->
            call.respond(HttpStatusCode.BadRequest, Response.Err("bad request! ${cause.message}"))
        }


        exception<Exception> { call, cause ->
            call.respond(HttpStatusCode.InternalServerError, Response.Err("there is an error in the server"))
        }

        exception<NotFoundException> { call, cause ->
            call.respond(HttpStatusCode.NotFound, Response.Err("not found: ${cause.message}"))
        }

        exception<NumberFormatException> { call, cause ->
            call.respond(HttpStatusCode.BadRequest, Response.Err("bad request! ${cause.message}"))
        }
    }
}