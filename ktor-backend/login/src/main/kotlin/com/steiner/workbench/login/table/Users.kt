package com.steiner.workbench.login.table

import com.steiner.workbench.common.`user-email-length`
import com.steiner.workbench.common.`user-name-length`
import com.steiner.workbench.common.`user-password-hash-length`
import org.jetbrains.exposed.dao.id.IntIdTable

object Users: IntIdTable() {
    val name = varchar("name", `user-name-length`).uniqueIndex()
    val email = varchar("email", `user-email-length`)
    val enabled = bool("enabled")
    val passwordHash = varchar("password-hash", `user-password-hash-length`)
}