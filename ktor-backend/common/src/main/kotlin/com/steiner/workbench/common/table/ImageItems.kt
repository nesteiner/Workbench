package com.steiner.workbench.common.table

import com.steiner.workbench.common.`image-item-name-length`
import com.steiner.workbench.common.`image-item-path-length`
import org.jetbrains.exposed.dao.id.IntIdTable

object ImageItems: IntIdTable() {
    val name = varchar("name", `image-item-name-length`)
    val path = varchar("path", `image-item-path-length`)
}