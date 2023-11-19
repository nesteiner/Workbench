package com.steiner.workbench.daily_attendance.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class Icon {
    @Serializable
    @SerialName("Image")
    class Image(val entryId: Int, val backgroundId: Int, val backgroundColor: String): Icon()

    @Serializable
    @SerialName("Word")
    // color is hex
    class Word(val char: Char, val color: String): Icon()
}