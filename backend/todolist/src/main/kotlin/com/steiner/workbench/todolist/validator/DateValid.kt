package com.steiner.workbench.todolist.validator

import jakarta.validation.Constraint
import jakarta.validation.Payload
import kotlin.reflect.KClass

@Constraint(validatedBy = [DateValidator::class])
@Target(AnnotationTarget.FIELD, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
annotation class DateValid(
        val message: String = "Invalid DateTime",
        val format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
        val groups: Array<KClass<*>> = arrayOf(),
        val payload: Array<KClass<out Payload>> = arrayOf()
)

