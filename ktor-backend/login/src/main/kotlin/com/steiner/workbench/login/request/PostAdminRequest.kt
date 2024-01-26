package com.steiner.workbench.login.request

class PostAdminRequest(
    val username: String,
    val email: String,
    val enabled: Boolean,
    val passwordHash: String
)