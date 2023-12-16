package com.steiner.workbench.samba.model

import java.util.Date

data class SambaFile(
    val name: String,
    val path: String,
    val lastModified: Date,
    val attributes: Int,
    val size: Long?,
    val filetype: FileType
)