package com.steiner.workbench.todolist.util

import com.steiner.workbench.common.exception.BadRequestException
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.select

fun mustExistIn(id: Int?, table: IntIdTable): Boolean {
    if (id == null) {
        return true
    }

    val ifid = table.select(table.id eq id).firstOrNull()
    return if (ifid != null) {
        true
    } else {
        throw BadRequestException("element not exist")
    }
}