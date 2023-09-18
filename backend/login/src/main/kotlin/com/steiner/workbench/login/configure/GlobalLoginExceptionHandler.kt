package com.steiner.workbench.login.configure

import com.steiner.workbench.common.util.Response
import com.steiner.workbench.login.exception.LoginException
import com.steiner.workbench.login.exception.UserNotEnabledException
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestControllerAdvice

@RestControllerAdvice
class GlobalLoginExceptionHandler {
    @ExceptionHandler(LoginException::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    fun handleException(exception: LoginException): Response.Err {
        val message = exception.message
        return Response.Err(message)
    }

    @ExceptionHandler(UserNotEnabledException::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    fun handleException(exception: UserNotEnabledException): Response.Err {
        val message = exception.message
        return Response.Err(message)
    }
}