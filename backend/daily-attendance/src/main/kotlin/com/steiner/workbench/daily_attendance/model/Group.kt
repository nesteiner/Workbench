package com.steiner.workbench.daily_attendance.model

import kotlinx.serialization.Serializable

@Serializable
enum class Group {
    Noon,
    Afternoon,
    Night,
    Other
}