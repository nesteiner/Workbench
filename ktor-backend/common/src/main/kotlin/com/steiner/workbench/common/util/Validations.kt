package com.steiner.workbench.common.util

import io.ktor.server.plugins.requestvalidation.*
import com.steiner.workbench.common.`common-string-length-min`
import com.steiner.workbench.common.emailRegex
import com.steiner.workbench.common.hexColorRegex

fun length(data: String?, min: Int = `common-string-length-min`, max: Int = Int.MAX_VALUE, message: String? = null): ValidationResult {
    if (data == null) {
        return ValidationResult.Valid
    }

    val message1 = message ?: "length of data should between ($min..$max)"

    val length = data.length
    return if (length !in (min..max)) {
        ValidationResult.Invalid(message1)
    } else {
        ValidationResult.Valid
    }
}

fun between(data: Int?, min: Int = 1, max: Int = Int.MAX_VALUE, message: String? = null): ValidationResult {
    if (data == null) {
        return ValidationResult.Valid
    }

    val message1 = message ?: "data should between ($min..$max)"

    val length = data
    return if (length !in (min..max)) {
        ValidationResult.Invalid(message1)
    } else {
        ValidationResult.Valid
    }
}

fun min(data: Int?, value: Int, message: String? = null): ValidationResult {
    if (data == null) {
        return ValidationResult.Valid
    }

    val message1 = message ?: "length of data should >= $value"

    return if (data < value) {
        ValidationResult.Invalid(message1)
    } else {
        ValidationResult.Valid
    }
}

fun max(data: Int?, value: Int, message: String? = null): ValidationResult {
    if (data == null) {
        return ValidationResult.Valid
    }

    val message1 = message ?: "length of data should <= $value"

    return if (data > value) {
        ValidationResult.Invalid(message1)
    } else {
        ValidationResult.Valid
    }
}

fun email(data: String?, message: String? = null): ValidationResult {
    if (data == null) {
        return ValidationResult.Valid
    }

    val message1 = message ?: "email pattern not correct"

    return if (emailRegex.matches(data)) {
        ValidationResult.Valid
    } else {
        ValidationResult.Invalid(message1)
    }
}

fun color(data: String?, message: String? = null): ValidationResult {
    if (data == null) {
        return ValidationResult.Valid
    }

    val message1 = message ?: "color pattern not correct"

    return if (hexColorRegex.matches(data)) {
        ValidationResult.Valid
    } else {
        ValidationResult.Invalid(message1)
    }
}