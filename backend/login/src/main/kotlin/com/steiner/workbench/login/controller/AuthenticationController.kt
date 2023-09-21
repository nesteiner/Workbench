package com.steiner.workbench.login.controller

import com.steiner.workbench.common.util.Response
import com.steiner.workbench.login.exception.LoginException
import com.steiner.workbench.login.exception.UserNotEnabledException
import com.steiner.workbench.login.request.LoginRequest
import com.steiner.workbench.login.response.LoginResponse
import com.steiner.workbench.login.service.UserService
import com.steiner.workbench.login.util.JwtTokenUtil
import jakarta.validation.Valid
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.authentication.DisabledException
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.Authentication
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.validation.BindingResult
import org.springframework.validation.annotation.Validated
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RestController

@RestController
@Validated
class AuthenticationController {
    @Autowired
    lateinit var jwtTokenUtil: JwtTokenUtil
    @Autowired
    lateinit var userService: UserService

    @PostMapping("/authenticate")
    fun createToken(@RequestBody @Valid request: LoginRequest, result: BindingResult): Response<LoginResponse> {
        try {
            val userdetail = userService.loadUserByUsername(request.username)
            val user = userService.findOne(request.username)!!

            if (!user.enabled) {
                throw UserNotEnabledException("user ${request.username} not enabled")
            }

            if (request.passwordHash != userdetail.password) {
                throw LoginException("password error")
            }

            val authentication: Authentication = UsernamePasswordAuthenticationToken(userdetail, null, userdetail.authorities)
            SecurityContextHolder.getContext().authentication = authentication

            val token = jwtTokenUtil.generateToken(userdetail)
            return Response.Ok("login success", LoginResponse(token))
        } catch (exception: DisabledException) {
            throw LoginException("user disabled")
        } catch (exception: BadCredentialsException) {
            throw LoginException("no such user or password")
        }
    }
}