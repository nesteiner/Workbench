package com.steiner.workbench.daily_attendance.model

import kotlinx.datetime.DayOfWeek
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class Frequency {
    /// 按天
    @Serializable
    @SerialName("Days")
    class Days(val weekdays: Array<DayOfWeek>): Frequency()

    /// 按周，每天几周
    @Serializable
    @SerialName("CountInWeek")
    class CountInWeek(val count: Int): Frequency()

    /// 按时间间隔,每几天一次
    @Serializable
    @SerialName("Interval")
    class Interval(val count: Int): Frequency()
}