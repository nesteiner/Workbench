package com.steiner.workbench.login.filter

import com.fasterxml.jackson.databind.ObjectMapper
import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.common.util.Response
import com.steiner.workbench.login.exception.UserNotEnabledException
import com.steiner.workbench.login.service.UserService
import com.steiner.workbench.login.util.JwtTokenUtil
import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter

@Component
class AuthenticationFilter: OncePerRequestFilter() {
    @Autowired
    lateinit var jwtTokenUtil: JwtTokenUtil
    @Autowired
    lateinit var userService: UserService

    override fun doFilterInternal(request: HttpServletRequest, response: HttpServletResponse, filterChain: FilterChain) {
        val username = request.getAttribute("username") as String?
        val jwttoken = request.getAttribute("jwttoken") as String?

        if (username != null && jwttoken != null && SecurityContextHolder.getContext().authentication == null) {
            try {
                val userdetail = userService.loadUserByUsername(username)
                val user = userService.findOne(username)!!

                if (!user.enabled) {
                    throw UserNotEnabledException("user ${username} not enabled")
                }

                if (jwtTokenUtil.validateToken(jwttoken, userdetail)) {
                    val token = UsernamePasswordAuthenticationToken(
                            userdetail, null, userdetail.authorities
                    )

                    token.details = WebAuthenticationDetailsSource().buildDetails(request)
                    SecurityContextHolder.getContext().authentication = token
                }

            } catch (exception: UsernameNotFoundException) {
                val objectMapper = ObjectMapper()
                val result = Response.Err(exception.message ?: "username not found")
                response.status = 401
                response.writer.write(objectMapper.writeValueAsString(result))
                return
            } catch (exception: UserNotEnabledException) {
                val objectMapper = ObjectMapper()
                val result = Response.Err(exception.message)
                response.status = 401
                response.writer.write(objectMapper.writeValueAsString(result))
                return
            }


        }

        filterChain.doFilter(request, response)
    }

}