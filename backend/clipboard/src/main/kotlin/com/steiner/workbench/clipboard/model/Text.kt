package com.steiner.workbench.clipboard.model

import kotlinx.datetime.Instant

class Text(
    val id: Int,
    val text: String,
    val createTime: Instant,
    val userid: Int
)