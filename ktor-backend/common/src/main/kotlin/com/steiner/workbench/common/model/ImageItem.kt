package com.steiner.workbench.common.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.Transient

@Serializable
class ImageItem(
    val id: Int,
    val name: String,
    @Transient
    val path: String? = null
)