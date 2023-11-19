package com.steiner.workbench.daily_attendance.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class Goal {
    @Serializable
    @SerialName("CurrentDay")
    object CurrentDay: Goal()
    @Serializable
    @SerialName("Amount")
    class Amount(val total: Int, val unit: String, val eachAmount: Int): Goal()
}