package com.steiner.workbench.common.util

import kotlinx.serialization.Serializable


sealed class Response<T> {
    @Serializable
    data class Ok<T>(val message: String, val data: T): Response<T>()

    @Serializable
    data class Err(val message: String): Response<Unit>()
}