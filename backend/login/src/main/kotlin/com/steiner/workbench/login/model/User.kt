package com.steiner.workbench.login.model

import com.fasterxml.jackson.annotation.JsonIgnore

class User(
        val id: Int,
        var name: String,
        var roles: List<Role>,
        var email: String,
        var enabled: Boolean,
        @JsonIgnore
        val passwordHash: String
)
