package com.steiner.workbench.todolist.validator

import com.steiner.workbench.common.ISO8601_FORMAT
import jakarta.validation.Constraint
import jakarta.validation.Payload
import kotlin.reflect.KClass

@Constraint(validatedBy = [DateValidator::class])
@Target(AnnotationTarget.FIELD, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
annotation class DateValid(
        val message: String = "Invalid DateTime",
        val format: String = ISO8601_FORMAT,
        val groups: Array<KClass<*>> = arrayOf(),
        val payload: Array<KClass<out Payload>> = arrayOf()
)

