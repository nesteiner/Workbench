package com.steiner.workbench.daily_attendance.service

import com.steiner.workbench.daily_attendance.model.ImageItem
import com.steiner.workbench.daily_attendance.table.ImageItems
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.select
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class IconService {
    fun insertIconImage(name: String, path: String): ImageItem {
        val id = ImageItems.insert {
            it[ImageItems.name] = name
            it[ImageItems.path] = path
        } get ImageItems.id

        return ImageItem(id.value, name, path)
    }

    fun findIconImage(id: Int): ImageItem? {
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