package com.steiner.workbench.login.filter

import com.fasterxml.jackson.databind.ObjectMapper
import com.steiner.workbench.common.AUTHORIZATIOIN
import com.steiner.workbench.common.JWTTOKEN_ATTRIBUTE
import com.steiner.workbench.common.USERNAME_ATTRIBUTE
import com.steiner.workbench.common.util.Response
import com.steiner.workbench.login.util.JwtTokenUtil
import io.jsonwebtoken.ExpiredJwtException
import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter

@Component
class LoginFilter: OncePerRequestFilter() {
    @Autowired
    lateinit var jwtTokenUtil: JwtTokenUtil

    override fun doFilterInternal(request: HttpServletRequest, response: HttpServletResponse, filterChain: FilterChain) {
        response.contentType = "application/json; charset=utf-8"
        val requestTokenHeader = request.getHeader(AUTHORIZATIOIN)
        val objectMapper = ObjectMapper()
        // enter request logic
        if(requestTokenHeader != null && requestTokenHeader.startsWith("Bearer ")) {
            val jwtToken = requestTokenHeader.split(" ")[1].trim()
            try {
                val username = jwtTokenUtil.getUsernameFromToken(jwtToken)
                request.setAttribute(USERNAME_ATTRIBUTE, username)
                request.setAttribute(JWTTOKEN_ATTRIBUTE, jwtToken)
            } catch (exception: IllegalArgumentException) {
                logger.error("unable to get jwt token")
                val result = Response.Err("no token found")
                response.status = 401
                response.writer.write(objectMapper.writeValueAsString(result))
                return
            } catch (exception: ExpiredJwtException) {
                logger.error("jwt token has been expired")
                val result = Response.Err("token expired")
                response.status = 401
                response.writer.write(objectMapper.writeValueAsString(result))
                return
            } catch (exception: Exception) {
                logger.error("unknown error")
                val result = Response.Err("unknow error")
                response.status = 401
                response.writer.write(objectMapper.writeValueAsString(result))
                return
            } finally {
                // response.setHeader("Access-Control-ALlow-Origin", "*");
            }
        } else if (requestTokenHeader != null && !requestTokenHeader.startsWith("Bearer ")) {
            logger.warn("jwt token does not begin with bearer string")
            val result = Response.Err("jwt token does not begin with bearer string")
            response.status = 401
            response.writer.write(objectMapper.writeValueAsString(result))
            return
        }

        filterChain.doFilter(request, response)
    }

}