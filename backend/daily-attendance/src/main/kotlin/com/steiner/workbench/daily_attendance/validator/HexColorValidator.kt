package com.steiner.workbench.daily_attendance.validator

import jakarta.validation.ConstraintValidator
import jakarta.validation.ConstraintValidatorContext

class HexColorValidator: ConstraintValidator<HexColorValid, String> {
    private val format = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"
    private val regex = Regex(format)
    override fun initialize(constraintAnnotation: HexColorValid?) {
        super.initialize(constraintAnnotation)
    }

    override fun isValid(value: String?, context: ConstraintValidatorContext): Boolean {
        if (value == null) {
            return true
        }

        return regex.matches(value)
    }
}