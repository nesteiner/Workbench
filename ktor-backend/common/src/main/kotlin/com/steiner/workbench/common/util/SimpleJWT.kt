package com.steiner.workbench.common.util

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm

open class SimpleJWT(secret: String) {
    private val algorithm = Algorithm.HMAC256(secret)
    val verifier = JWT.require(algorithm).build()
    fun sign(id: Int, name: String): String = JWT.create()
        .withClaim("id", id)
        .withClaim("name", name)
        .sign(algorithm)
}