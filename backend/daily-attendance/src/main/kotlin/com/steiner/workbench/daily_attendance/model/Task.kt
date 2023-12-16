package com.steiner.workbench.daily_attendance.model

import com.steiner.workbench.daily_attendance.serializer.LocalDateSerializer
import kotlinx.datetime.LocalDate
import kotlinx.serialization.Serializable

@Serializable
class Task(
        val id: Int,
        val name: String,
        val icon: Icon,
        val encouragement: String,

        val frequency: Frequency,

        val goal: Goal,

        @Serializable(with = LocalDateSerializer::class)
        val startTime: LocalDate,

        val keepdays: KeepDays,
        val group: Group,

        val notifyTimes: Array<NotifyTime>,

        val progress: Progress,

        val isarchived: Boolean,
        val userid: Int,
        val consecutiveDays: Int,
        val persistenceDays: Int
) {
        override fun equals(other: Any?): Boolean {
                return when (other) {
                        !is Task -> false
                        else -> id == other.id
                }
        }
}