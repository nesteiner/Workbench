package com.steiner.workbench.daily_attendance.model

import kotlinx.serialization.Serializable

@Serializable
class ImageItem(
        val id: Int,
        val name: String,
        val path: String
)