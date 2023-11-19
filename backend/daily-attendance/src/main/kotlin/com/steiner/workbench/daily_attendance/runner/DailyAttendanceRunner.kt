package com.steiner.workbench.daily_attendance.runner

import com.steiner.workbench.daily_attendance.model.*
import com.steiner.workbench.daily_attendance.request.PostTaskRequest
import com.steiner.workbench.daily_attendance.service.DailyAttendanceService
import com.steiner.workbench.daily_attendance.table.TaskEvents
import com.steiner.workbench.daily_attendance.table.Tasks
import com.steiner.workbench.login.service.UserService
import kotlinx.datetime.LocalDate
import org.jetbrains.exposed.sql.SchemaUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.ApplicationArguments
import org.springframework.boot.ApplicationRunner
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.time.DayOfWeek

@Component
@Transactional
class DailyAttendanceRunner: ApplicationRunner {
    @Autowired
    lateinit var dailyAttendanceService: DailyAttendanceService
    @Autowired
    lateinit var userService: UserService

    override fun run(args: ApplicationArguments?) {
        SchemaUtils.drop(TaskEvents)
        SchemaUtils.drop(Tasks)
        SchemaUtils.create(Tasks)
        SchemaUtils.create(TaskEvents)

        val requests = listOf<PostTaskRequest>(
                PostTaskRequest(
                        name = "背单词",
                        encouragement = "学习一门语言当然要背单词啦",
                        frequency = Frequency.Interval(2),
                        goal = Goal.Amount(5, "页", 1),
                        group = Group.Afternoon,
                        icon = Icon.Word(char = '你', color = "#4295f5"),
                        keepdays = KeepDays.Forever,
                        notifyTimes = arrayOf(NotifyTime(13, 0)),
                        userid = userService.findOne("steiner")!!.id
                ),

                PostTaskRequest(
                        name = "阅读",
                        encouragement = "有空看看书，说不定会有新收获",
                        frequency = Frequency.Days(arrayOf(DayOfWeek.MONDAY, DayOfWeek.TUESDAY, DayOfWeek.WEDNESDAY, DayOfWeek.THURSDAY, DayOfWeek.FRIDAY, DayOfWeek.SATURDAY, DayOfWeek.SUNDAY)),
                        goal = Goal.CurrentDay,
                        group = Group.Night,
                        icon = Icon.Word(char = '好', color = "#f54293"),
                        keepdays = KeepDays.Forever,
                        notifyTimes = arrayOf(NotifyTime(20, 0)),
                        userid = userService.findOne("steiner")!!.id
                ),

                PostTaskRequest(
                        name = "吃水果",
                        encouragement = "饭后来电水果就更棒了",
                        frequency = Frequency.CountInWeek(2),
                        goal = Goal.CurrentDay,
                        group = Group.Other,
                        icon = Icon.Word(char = '世', color = "#78f542"),
                        keepdays = KeepDays.Forever,
                        notifyTimes = arrayOf(),
                        userid = userService.findOne("steiner")!!.id
                ),
        )

        requests.forEach {
            dailyAttendanceService.insertOne(it)
        }
    }
}