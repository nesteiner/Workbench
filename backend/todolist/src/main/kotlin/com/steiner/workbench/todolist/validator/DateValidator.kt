package com.steiner.workbench.todolist.validator

import jakarta.validation.ConstraintValidator
import jakarta.validation.ConstraintValidatorContext
import org.slf4j.LoggerFactory
import java.text.SimpleDateFormat

class DateValidator: ConstraintValidator<DateValid, String> {
    companion object {
        val logger = LoggerFactory.getLogger(DateValidator::class.java)
    }

    lateinit var format: String
    override fun initialize(constraintAnnotation: DateValid) {
        format = constraintAnnotation.format
    }

    override fun isValid(value: String?, context: ConstraintValidatorContext): Boolean {
        if (value == null) {
            return true
        }

        return try {
            val sdf = SimpleDateFormat(format)
            sdf.parse(value)
            true
        } catch (exception: Exception) {
            false
        }
    }
}