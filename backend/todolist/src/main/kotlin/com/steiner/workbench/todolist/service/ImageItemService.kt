package com.steiner.workbench.todolist.service

import com.steiner.workbench.todolist.model.ImageItem
import com.steiner.workbench.todolist.table.ImageItems
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.deleteWhere
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.select
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class ImageItemService {
    fun insertOne(name: String, path: String): ImageItem {
        val id = ImageItems.insert {
            it[ImageItems.name] = name
            it[ImageItems.path] = path
        } get ImageItems.id

        return ImageItem(id.value, name, path)
    }

    fun deleteOne(id: Int) {
        ImageItems.deleteWhere {
            ImageItems.id eq id
        }
    }

    fun findOne(id: Int): ImageItem? {
        return ImageItems.select(ImageItems.id eq id)
                .firstOrNull()
                ?.let {
                    ImageItem(
                            id = id,
                            name = it[ImageItems.name],
                            path = it[ImageItems.path]
                    )
                }
    }
}