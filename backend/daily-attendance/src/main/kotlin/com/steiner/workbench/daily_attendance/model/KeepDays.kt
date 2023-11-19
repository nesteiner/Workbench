package com.steiner.workbench.daily_attendance.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class KeepDays {
    @Serializable
    @SerialName("Forever")
    object Forever: KeepDays()
    @Serializable
    @SerialName("Manual")
    class Manual(val days: Int): KeepDays()
}