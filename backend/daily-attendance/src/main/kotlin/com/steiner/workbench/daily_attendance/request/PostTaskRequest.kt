package com.steiner.workbench.daily_attendance.request

import com.steiner.workbench.common.*
import com.steiner.workbench.daily_attendance.model.*
import com.steiner.workbench.daily_attendance.serializer.*
import jakarta.validation.constraints.NotEmpty
import kotlinx.datetime.LocalDate
import kotlinx.serialization.Serializable
import org.hibernate.validator.constraints.Length

@Serializable
class PostTaskRequest(
        @NotEmpty(message = "name cannot be empty")
        @Length(max = DAILY_ATTENDANCE_NAME_LENGTH, message = "length of name must less than $DAILY_ATTENDANCE_NAME_LENGTH")
        val name: String,

        val icon: Icon,

        @NotEmpty(message = "encouragement cannot be empty")
        @Length(max = DAILY_ATTENDANCE_ENCOURAGEMENT_LENGTH, message = "length of name must less than $DAILY_ATTENDANCE_ENCOURAGEMENT_LENGTH")
        val encouragement: String,

        val frequency: Frequency,

        val goal: Goal,

        val keepdays: KeepDays,

        val group: Group,

        @Serializable(with = LocalDateSerializer::class)
        val startTime: LocalDate,

        val notifyTimes: Array<NotifyTime>,
        val userid: Int
)


