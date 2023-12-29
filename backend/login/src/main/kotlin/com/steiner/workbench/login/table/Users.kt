package com.steiner.workbench.login.table

import com.steiner.workbench.common.USER_EMAIL_LENGTH
import com.steiner.workbench.common.USER_NAME_LENGTH
import org.jetbrains.exposed.dao.id.IntIdTable

object Users: IntIdTable() {
    val name = varchar("name", USER_NAME_LENGTH).uniqueIndex()
    val email = varchar("email", USER_EMAIL_LENGTH)
    val enabled = bool("enabled")
    val passwordHash = varchar("passwordHash", 256)
}