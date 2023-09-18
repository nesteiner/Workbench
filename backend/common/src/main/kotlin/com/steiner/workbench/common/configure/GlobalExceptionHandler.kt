package com.steiner.workbench.common.configure

import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.common.util.Response
import jakarta.validation.ConstraintViolationException
import org.springframework.http.HttpStatus
import org.springframework.security.core.AuthenticationException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestControllerAdvice

@RestControllerAdvice
class GlobalExceptionHandler {
    @ExceptionHandler(AuthenticationException::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    fun handleException(exception: AuthenticationException): Response.Err {
        val message = exception.message ?: "username not found"
        return Response.Err(message)
    }

    @ExceptionHandler(ConstraintViolationException::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    fun handleException(exception: ConstraintViolationException): Response<Unit> {
        val message = StringBuilder()
        val constraintViolations = exception.constraintViolations
        constraintViolations.forEach { constraintViolation ->
            val _message = constraintViolation.message
            message.append("[").append(_message).append("]")
        }

        return Response.Err(message.toString())
    }

    @ExceptionHandler(BadRequestException::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    fun handleException(exception: BadRequestException): Response.Err {
        val message = exception.message
        return Response.Err(message)
    }

    @ExceptionHandler(Exception::class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    fun handleException(exception: Exception): Response.Err {
        val message = exception.message ?: "Internal exception occurs"
        exception.printStackTrace()
        return Response.Err(message)
    }
}