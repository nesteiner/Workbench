package com.steiner.workbench.app.plugin

import com.steiner.workbench.common.util.SimpleJWT
import com.steiner.workbench.login.exception.AuthenticationException
import com.steiner.workbench.login.principal.IdPrincipal
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import com.steiner.workbench.common.`normal-jwt`
import org.koin.ktor.ext.inject

fun Application.configureSecurity() {
    val simpleJWT: SimpleJWT by inject<SimpleJWT>()

    authentication {
        jwt(`normal-jwt`) {
            verifier(simpleJWT.verifier)
            challenge { defaultScheme, realm ->
                call.request.headers["Authorizatioon"].let {
                    if (it == null) {
                        throw AuthenticationException("no token")
                    }

                    if (it.isEmpty()) {
                        throw AuthenticationException("token empty")
                    }

                    if (!it.startsWith("Bearer")) {
                        throw AuthenticationException("token must start with Bearer")
                    }
                }
            }

            validate {
                IdPrincipal(it.payload.getClaim("id").asInt())
            }
        }
    }
}