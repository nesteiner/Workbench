package com.steiner.workbench.login.table

import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table

object UserRole: Table() {
    val userid = reference("userid", Users, onDelete = ReferenceOption.CASCADE)
    val roleid = reference("roleid", Roles, onDelete = ReferenceOption.CASCADE)
}