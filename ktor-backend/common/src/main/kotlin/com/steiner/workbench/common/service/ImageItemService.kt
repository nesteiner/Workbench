package com.steiner.workbench.common.service

import com.steiner.workbench.common.model.ImageItem
import com.steiner.workbench.common.table.ImageItems
import com.steiner.workbench.common.util.dbQuery
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction

class ImageItemService(val database: Database) {
    init {
        transaction(database) {
            SchemaUtils.create(ImageItems)
        }
    }

    suspend fun insertOne(name: String, path: String): ImageItem = dbQuery(database) {
        val id = with (ImageItems) {
            insert {
                it[this.name] = name
                it[this.path] = path
            } get this.id
        }

        findOne(id.value)!!
    }

    suspend fun deleteOne(id: Int) = dbQuery(database) {
        ImageItems.deleteWhere {
            this.id eq id
        }
    }

    suspend fun findOne(id: Int): ImageItem? = dbQuery(database) {
        with (ImageItems) {
            selectAll().where(this.id eq id)
                .firstOrNull()
                ?.let {
                    ImageItem(
                        id = id,
                        name = it[name],
                        path = it[path]
                    )
                }
        }
    }


}