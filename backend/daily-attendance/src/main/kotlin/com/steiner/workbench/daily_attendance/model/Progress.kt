package com.steiner.workbench.daily_attendance.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class Progress {
    @Serializable
    @SerialName("NotScheduled")
    object NotScheduled: Progress()

    @Serializable
    @SerialName("Ready")
    object Ready: Progress()

    @Serializable
    @SerialName("Done")
    object Done: Progress()

    @Serializable
    @SerialName("Doing")
    class Doing(val total: Int, val unit: String, val amount: Int): Progress()
}