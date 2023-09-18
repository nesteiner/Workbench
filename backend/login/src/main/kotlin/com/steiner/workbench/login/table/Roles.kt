package com.steiner.workbench.login.table

import org.jetbrains.exposed.dao.id.IntIdTable

object Roles: IntIdTable() {
    val name = varchar("name", 32)
}