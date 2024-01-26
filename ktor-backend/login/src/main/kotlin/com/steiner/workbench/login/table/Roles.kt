package com.steiner.workbench.login.table

import com.steiner.workbench.common.`role-name-length`
import org.jetbrains.exposed.dao.id.IntIdTable

object Roles: IntIdTable() {
    val name = varchar("name", `role-name-length`)
}