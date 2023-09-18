package com.steiner.workbench.login.table

import org.jetbrains.exposed.sql.Table

object UserRole: Table() {
    val userid = reference("userid", Users)
    val roleid = reference("roleid", Roles)
}