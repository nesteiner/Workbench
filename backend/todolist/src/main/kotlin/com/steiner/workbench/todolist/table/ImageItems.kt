package com.steiner.workbench.todolist.table

import com.steiner.workbench.common.IMAGE_ITEM_NAME_LENGTH
import com.steiner.workbench.common.IMAGE_ITEM_PATH_LENGTH
import org.jetbrains.exposed.dao.id.IntIdTable

object ImageItems: IntIdTable("todolist-imageitems") {
    val name = varchar("name", IMAGE_ITEM_NAME_LENGTH)
    val path = varchar("path", IMAGE_ITEM_PATH_LENGTH)
}