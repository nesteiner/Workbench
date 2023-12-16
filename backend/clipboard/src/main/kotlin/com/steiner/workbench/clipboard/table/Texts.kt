package com.steiner.workbench.clipboard.table

import com.steiner.workbench.common.CLIPBOARD_TEXT_LENGTH
import com.steiner.workbench.login.table.Users
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.kotlin.datetime.timestamp

object Texts: IntIdTable("clipboard-texts") {
    val text = varchar("text", CLIPBOARD_TEXT_LENGTH)
    val createTime = timestamp("createTime")
    val userid = reference("userid", Users, onDelete = ReferenceOption.CASCADE)
}