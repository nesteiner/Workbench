package com.steiner.workbench.daily_attendance.table


import com.steiner.workbench.common.DAILY_ATTENDANCE_ENCOURAGEMENT_LENGTH
import com.steiner.workbench.common.DAILY_ATTENDANCE_NAME_LENGTH
import com.steiner.workbench.daily_attendance.model.*
import com.steiner.workbench.login.table.Users
import kotlinx.serialization.json.Json
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.json.jsonb
import org.jetbrains.exposed.sql.kotlin.datetime.date

private val formatter = Json { prettyPrint = true }
object Tasks: IntIdTable(name = "DailyAttendanceTasks") {
    val name = varchar("name", DAILY_ATTENDANCE_NAME_LENGTH).uniqueIndex()
    val icon = jsonb<Icon>("icon", formatter)
    val encouragement = varchar("encouragement", DAILY_ATTENDANCE_ENCOURAGEMENT_LENGTH)
    val frequency = jsonb<Frequency>("frequency", formatter)
    val goal = jsonb<Goal>("goal", formatter)
    val startTime = date("startTime")
    val keepdays = jsonb<KeepDays>("keepdays", formatter)
    val group = jsonb<Group>("group", formatter)
    val notifyTimes = jsonb<Array<NotifyTime>>("notifyTimes", formatter)
    val progress = jsonb<Progress>("progress", formatter)

    val isarchived = bool("isarchived")
    val userid = reference("userid", Users)
    val consecutiveDays = integer("consecutiveDays")
    val persistenceDays = integer("persistenceDays")
}