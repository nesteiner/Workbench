package com.steiner.workbench.daily_attendance.model

import kotlinx.datetime.DayOfWeek
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class Frequency {
    @Serializable
    @SerialName("Days")
    // 按天
    class Days(val weekdays: Array<DayOfWeek>): Frequency()
    @Serializable
    @SerialName("CountInWeek")
    // 按周，每天几周
    class CountInWeek(val count: Int): Frequency()
    @Serializable
    @SerialName("Interval")
    // 按时间间隔
    class Interval(val count: Int): Frequency()
}