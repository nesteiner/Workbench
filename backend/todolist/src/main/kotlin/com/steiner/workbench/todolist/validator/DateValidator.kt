package com.steiner.workbench.todolist.validator

import jakarta.validation.ConstraintValidator
import jakarta.validation.ConstraintValidatorContext
import java.text.SimpleDateFormat

class DateValidator: ConstraintValidator<DateValid, String> {
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
            sdf.isLenient = false

            sdf.parse(value)
            true
        } catch (exception: Exception) {
            false
        }
    }
}