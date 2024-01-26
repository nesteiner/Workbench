package com.steiner.workbench.login.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient

@Serializable
class User(
    val id: Int,
    val name: String,
    val roles: List<Role>,
    val enabled: Boolean,
    val email: String,
    @Transient
    val passwordHash: String? = null
)