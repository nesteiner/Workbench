package com.steiner.workbench.daily_attendance.request

import com.steiner.workbench.common.DAILY_ATTENDANCE_ENCOURAGEMENT_LENGTH
import com.steiner.workbench.common.DAILY_ATTENDANCE_NAME_LENGTH
import com.steiner.workbench.daily_attendance.model.*
import com.steiner.workbench.daily_attendance.serializer.LocalDateSerializer
import jakarta.validation.constraints.NotEmpty
import kotlinx.datetime.LocalDate
import kotlinx.serialization.Serializable
import org.hibernate.validator.constraints.Length

@Serializable
class UpdateTaskRequest(
        val id: Int,
        @NotEmpty(message = "name cannot be empty")
        @Length(max = DAILY_ATTENDANCE_NAME_LENGTH, message = "length of name must less than $DAILY_ATTENDANCE_NAME_LENGTH")
        val name: String,
        val icon: Icon,

        @NotEmpty(message = "encouragement cannot be empty")
        @Length(max = DAILY_ATTENDANCE_ENCOURAGEMENT_LENGTH, message = "length of name must less than $DAILY_ATTENDANCE_ENCOURAGEMENT_LENGTH")
        val encouragement: String,
        val frequency: Frequency,
        val goal: Goal,

        @Serializable(with = LocalDateSerializer::class)
        val startTime: LocalDate,
        val keepdays: KeepDays,
        val group: Group,

        val notifyTimes: Array<NotifyTime>,
)