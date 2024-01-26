package com.steiner.workbench.todolist.util

import io.ktor.server.plugins.*
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq

fun mustExistIn(id: Int?, table: IntIdTable): Boolean {
    if (id == null) {
        return true
    }

    val exist = table.select(table.id eq id).firstOrNull() != null

    return if (exist) {
        true
    } else {
        throw BadRequestException("element not exist")
    }
}