package com.steiner.workbench.login.table

import org.jetbrains.exposed.dao.id.IntIdTable

object Users: IntIdTable() {
    val name = char("name", 24).uniqueIndex()
    val email = char("email", 24)
    val enabled = bool("enabled")
    val passwordHash = varchar("passwordHash", 256)
}