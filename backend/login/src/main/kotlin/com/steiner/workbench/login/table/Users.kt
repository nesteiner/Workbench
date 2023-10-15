package com.steiner.workbench.login.table

import org.jetbrains.exposed.dao.id.IntIdTable

object Users: IntIdTable() {
    val name = varchar("name", 24).uniqueIndex()
    val email = varchar("email", 24)
    val enabled = bool("enabled")
    val passwordHash = varchar("passwordHash", 256)
}