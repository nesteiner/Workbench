package com.steiner.workbench.clipboard.service

import com.steiner.workbench.clipboard.model.Text
import com.steiner.workbench.clipboard.request.PostTextRequest
import com.steiner.workbench.clipboard.table.Texts
import com.steiner.workbench.common.util.Page
import com.steiner.workbench.common.util.shanghaiNow
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.deleteWhere
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.select
import org.jetbrains.exposed.sql.selectAll
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import kotlin.math.ceil

@Service
@Transactional
class TextService {
    fun insertOne(request: PostTextRequest): Text {
        val id = Texts.insert {
            it[text] = request.text
            it[createTime] = shanghaiNow()
            it[userid] = request.userid
        } get Texts.id

        return findOne(id.value)!!
    }

    fun deleteOne(id: Int) {
        Texts.deleteWhere {
            this.id eq id
        }
    }

    fun findAll(userid: Int): List<Text> {
        return Texts.select(Texts.userid eq userid)
            .map {
                with (Texts) {
                    Text(
                        id = it[id].value,
                        text = it[text],
                        createTime = it[createTime],
                        userid = it[this.userid].value
                    )
                }
            }
    }

    fun findAll(userid: Int, page: Int, size: Int): Page<Text> {
        val content = Texts.select(Texts.userid eq userid)
            .limit(size, offset = page * size.toLong())
            .map {
                with (Texts) {
                    Text(
                        id = it[id].value,
                        text = it[text],
                        createTime = it[createTime],
                        userid = it[this.userid].value
                    )
                }
            }

        val totalPages = ceil(Texts.selectAll().count() / size.toDouble()).toInt()

        return Page(content, totalPages)
    }


    fun findOne(id: Int): Text? {
        return Texts.select(Texts.id eq id)
            .firstOrNull()
            ?.let {
                with (Texts) {
                    Text(
                        id = it[this.id].value,
                        text = it[text],
                        createTime = it[createTime],
                        userid = it[userid].value
                    )
                }
            }
    }
}