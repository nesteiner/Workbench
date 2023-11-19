package com.steiner.workbench.daily_attendance.model

import com.steiner.workbench.daily_attendance.serializer.*
import kotlinx.datetime.LocalDate
import kotlinx.serialization.Serializable

@Serializable
class Task(
        val id: Int,
        val name: String,
        @Serializable(with = IconSerializer::class)
        val icon: Icon,
        val encouragement: String,

        @Serializable(with = FrequencySerializer::class)
        val frequency: Frequency,

        @Serializable(with = GoalSerializer::class)
        val goal: Goal,

        @Serializable(with = LocalDateSerializer::class)
        val startTime: LocalDate,

        @Serializable(with = KeepDaysSerializer::class)
        val keepdays: KeepDays,
        val group: Group,

        val notifyTimes: Array<NotifyTime>,

        @Serializable(with = ProgressSerializer::class)
        val progress: Progress,

        val isarchived: Boolean,
        val userid: Int,
        val consecutiveDays: Int,
        val persistenceDays: Int
)