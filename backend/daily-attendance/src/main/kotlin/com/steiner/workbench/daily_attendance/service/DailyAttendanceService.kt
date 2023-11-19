package com.steiner.workbench.daily_attendance.service

import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.common.util.CURRENT_TIME_ZONE
import com.steiner.workbench.common.util.now
import com.steiner.workbench.daily_attendance.request.UpdateProgressRequest
import com.steiner.workbench.daily_attendance.table.Tasks
import com.steiner.workbench.daily_attendance.iterate.*
import com.steiner.workbench.daily_attendance.model.*
import com.steiner.workbench.daily_attendance.request.UpdateArchiveTaskRequest
import com.steiner.workbench.daily_attendance.request.PostTaskRequest
import com.steiner.workbench.daily_attendance.request.UpdateTaskRequest
import com.steiner.workbench.daily_attendance.table.TaskEvents
import kotlinx.datetime.*
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.greaterEq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.lessEq
import org.jetbrains.exposed.sql.kotlin.datetime.day
import org.jetbrains.exposed.sql.kotlin.datetime.month
import org.jetbrains.exposed.sql.kotlin.datetime.year
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import kotlin.time.DurationUnit
import kotlin.time.toDuration

@Service
@Transactional
class DailyAttendanceService {
    companion object {
        val dayDistance = mapOf(
                DayOfWeek.MONDAY to 0,
                DayOfWeek.TUESDAY to 1,
                DayOfWeek.WEDNESDAY to 2,
                DayOfWeek.THURSDAY to 3,
                DayOfWeek.FRIDAY to 4,
                DayOfWeek.SATURDAY to 5,
                DayOfWeek.SUNDAY to 6
        )
    }

    fun insertOne(request: PostTaskRequest): Task {
        val ifexists = Tasks.select(Tasks.name eq request.name.trim()).firstOrNull()
        if (ifexists != null) {
            throw BadRequestException("there is already a task named ${request.name}")
        }
        val currentDay = now()
        val currentDayLocalDate = currentDay.toLocalDateTime(CURRENT_TIME_ZONE).date

        val id = Tasks.insert {
            it[name] = request.name
            it[icon] = request.icon
            it[encouragement] = request.encouragement
            it[frequency] = request.frequency
            it[goal] = request.goal
            it[startTime] = currentDayLocalDate
            it[keepdays] = request.keepdays
            it[group] = request.group
            it[notifyTimes] = request.notifyTimes
            it[progress] = Progress.Ready
            it[isarchived] = false
            it[userid] = request.userid
            it[consecutiveDays] = 0
            it[persistenceDays] = 0
        } get Tasks.id

        return findOne(id.value)!!
    }

    fun deleteOne(id0: Int) {
        Tasks.deleteWhere {
            id eq id0
        }

        TaskEvents.deleteWhere {
            taskid eq id0
        }
    }

    fun archive(id0: Int) {
        Tasks.update({ Tasks.id eq id0 }) {
            it[isarchived] = true
        }
    }

    fun restore(id0: Int) {
        Tasks.update({ Tasks.id eq id0 }) {
            it[isarchived] = false
        }
    }

    fun updateOne(request: UpdateTaskRequest): Task {
        Tasks.update({ Tasks.id eq request.id }) {
            it[name] = request.name
            it[icon] = request.icon
            it[encouragement] = request.encouragement
            it[frequency] = request.frequency
            it[goal] = request.goal
            it[startTime] = request.startTime
            it[keepdays] = request.keepdays
            it[group] = request.group
            it[notifyTimes] = request.notifyTimes
        }

        return findOne(request.id) ?: throw BadRequestException("no such element")
    }

    fun updateProgress(request: UpdateProgressRequest): Task {
        var progress0: Progress = request.progress

        if (progress0 is Progress.Doing) {
            if (progress0.amount >= progress0.total) {
                progress0 = Progress.Done
            }
        }

        Tasks.update({ Tasks.id eq request.id }) {
            it[progress] = progress0
        }

        val now0 = now()
        Tasks.slice(Tasks.id, Tasks.name)
                .select(Tasks.id eq request.id)
                .first()
                .let {
                    val taskid0 = it[Tasks.id].value
                    val taskname0 = it[Tasks.name]

                    TaskEvents.insert {
                        it[taskid] = taskid0
                        it[taskname] = taskname0
                        it[time] = now0
                        it[progress] = progress0
                    }
                }

        return findOne(request.id) ?: throw BadRequestException("no such element")
    }

    fun updateArchive(request: UpdateArchiveTaskRequest) {
        Tasks.update({Tasks.id eq request.id}) {
            it[isarchived] = request.isarchive
        }
    }
    fun findOne(id: Int): Task? {
        return Tasks.select(Tasks.id eq id)
                .firstOrNull()
                ?.let {
                    return@let with (Tasks) {
                        Task(
                                id = id,
                                name = it[name],
                                icon = it[icon],
                                encouragement = it[encouragement],
                                frequency = it[frequency],
                                goal = it[goal],
                                startTime = it[startTime],
                                keepdays = it[keepdays],
                                group = it[group],
                                notifyTimes = it[notifyTimes],
                                progress = it[progress],
                                isarchived = it[isarchived],
                                userid = it[userid].value,
                                consecutiveDays = it[consecutiveDays],
                                persistenceDays = it[persistenceDays]
                        )
                    }

                }
    }

    /// find the tasks which is not archived
    fun findAll(userid: Int): List<Task> {
        val currentDay = now()
        val currentDayLocalDate = currentDay.toLocalDateTime(CURRENT_TIME_ZONE).date
        return findAll(currentDayLocalDate, userid)
    }

    fun findAll(localdate: LocalDate, userid: Int): List<Task> {
        return Tasks
                .select(
                        (Tasks.isarchived eq false)
                                and
                                (Tasks.startTime lessEq localdate)
                                and
                                (Tasks.progress eq Progress.Ready)
                                and
                                (Tasks.userid eq userid)
                ).filter {
                    val keepdays = it[Tasks.keepdays]
                    when (keepdays) {
                        is KeepDays.Forever -> true

                        is KeepDays.Manual -> {
                            val days = keepdays.days
                            val startTime = it[Tasks.startTime]
                            val endTime = startTime.plus(days, DateTimeUnit.DAY)

                            endTime >= localdate
                        }
                    }
                }.map {
                    findOne(it[Tasks.id].value)!!
                }
    }

    fun findLatest7Days(userid: Int): Map<DayOfWeek, List<Task>> {
        val currentDay = now()
        val currentDayLocalDate = currentDay.toLocalDateTime(CURRENT_TIME_ZONE).date
        val past7LocalDate = currentDay.minus(7.toDuration(DurationUnit.DAYS)).toLocalDateTime(CURRENT_TIME_ZONE).date

        val dayOfWeekRecord = HashMap<DayOfWeek, LocalDate>()

        for (date in past7LocalDate..currentDayLocalDate) {
            dayOfWeekRecord.put(date.dayOfWeek, date)
        }

        val result = HashMap<DayOfWeek, List<Task>>()

        (past7LocalDate..currentDayLocalDate).forEach {
            val value = findAll(it, userid)
            val key = it.dayOfWeek

            result.put(key, value)
        }


        return result.toSortedMap { left, right ->
            dayOfWeekRecord[left]!!.compareTo(dayOfWeekRecord[right]!!)
        }
    }

    fun refreshDataDaily() {
        // this should be called once a day
        // given a now instant, refresh progress by frequency and former progress
        val currentDay = now()
        val currentDayLocalDate = currentDay.toLocalDateTime(CURRENT_TIME_ZONE).date
        val yesterdayLocalDate = currentDayLocalDate.minus(DatePeriod(days = 1))

        Tasks.select((Tasks.isarchived eq false) and (Tasks.startTime lessEq currentDayLocalDate))
                .filter {
                    val keepday = it[Tasks.keepdays]
                    when (keepday) {
                        is KeepDays.Forever -> true
                        is KeepDays.Manual -> {
                            val startTime = it[Tasks.startTime]
                            val endTime = startTime.plus(keepday.days, DateTimeUnit.DAY)

                            endTime >= currentDayLocalDate
                        }
                    }
                }.forEach {
                    val id = it[Tasks.id].value
                    val frequency = it[Tasks.frequency]

                    Tasks.update({Tasks.id eq id}) {
                        it[progress] = Progress.Ready
                    }

                    when (frequency) {
                        is Frequency.Days -> {
                            if (!frequency.weekdays.contains(currentDayLocalDate.dayOfWeek)) {
                                Tasks.update({ Tasks.id eq id }) {
                                    it[progress] = Progress.NotScheduled
                                }
                            }
                        }

                        is Frequency.CountInWeek -> {
                            val count = frequency.count
                            val events = findAllEventsOfCurrentWeek(id)

                            val doneCount = events.count {
                                val task = findOne(it.taskid)!!
                                task.progress == Progress.Done
                            }

                            if (doneCount == count) {
                                Tasks.update({ Tasks.id eq id }) {
                                    it[progress] = Progress.NotScheduled
                                }
                            }
                        }

                        is Frequency.Interval -> {
                            val startTime = it[Tasks.startTime]
                            val nextTime = startTime.plus(frequency.count, DateTimeUnit.DAY)
                            if (!(isSameDay(startTime, currentDayLocalDate) || isSameDay(nextTime, currentDayLocalDate))) {
                                Tasks.update({ Tasks.id eq id }) {
                                    it[progress] = Progress.NotScheduled
                                }
                            }
                        }
                    }

                    // get the event of yesterday, check if there is done progress, if so, days += 1, else days = 0
                    val op = (TaskEvents.taskid eq id) and
                            (TaskEvents.time.year() eq yesterdayLocalDate.year) and
                            (TaskEvents.time.month() eq yesterdayLocalDate.monthNumber) and
                            (TaskEvents.time.day() eq yesterdayLocalDate.dayOfMonth)

                    val flag = TaskEvents.select(op).any {
                        val progress = it[TaskEvents.progress]
                        progress == Progress.Done
                    }


                    Tasks.update({ Tasks.id eq id }) {
                        if (flag) {
                            with (SqlExpressionBuilder) {
                                it.update(consecutiveDays, consecutiveDays + 1)
                                it.update(persistenceDays, persistenceDays + 1)
                            }
                        } else {
                            it[consecutiveDays] = 0
                        }
                    }

                }
    }

    fun findArchive(userid: Int): List<Task> {
        return Tasks.select((Tasks.isarchived eq true) and (Tasks.userid eq userid))
                .map {
                    findOne(it[Tasks.id].value)!!
                }
    }

    fun findAllEventsOfCurrentWeek(taskid: Int): List<TaskEvent> {
        val currentDay = now()
        val currentDayLocalDate = currentDay.toLocalDateTime(CURRENT_TIME_ZONE).date

        val distance = dayDistance[currentDayLocalDate.dayOfWeek]!!
        val startOfWeek = currentDay - distance.toDuration(DurationUnit.DAYS)
        val endOfWeek = startOfWeek + 7.toDuration(DurationUnit.DAYS)

        return TaskEvents.select(
                (TaskEvents.time greaterEq startOfWeek)
                        and
                        (TaskEvents.time lessEq endOfWeek)
        ).map {
            TaskEvent(
                    id = it[TaskEvents.id].value,
                    taskid = it[TaskEvents.taskid].value,
                    taskname = it[TaskEvents.taskname],
                    time = it[TaskEvents.time],
                    progress = it[TaskEvents.progress]
            )
        }

    }

    fun resetTaskCurrentDay(id: Int) {
        val currentDay = now()
        val currentDayLocalDate = currentDay.toLocalDateTime(CURRENT_TIME_ZONE).date

        Tasks.update({ Tasks.id eq id }) {
            it[progress] = Progress.Ready
        }

        // TODO delete the taskevents which is the same day with currentDay, and the id eq id
        TaskEvents.deleteWhere {
            val r1 = time.year() eq currentDayLocalDate.year
            val r2 = time.month() eq currentDayLocalDate.monthNumber
            val r3 = time.day() eq currentDayLocalDate.dayOfMonth
            r1 and r2 and r3
        }
    }
    private fun isSameDay(left: LocalDate, right: LocalDate): Boolean {
        return left.year == right.year && left.month == right.month && left.dayOfMonth == right.dayOfMonth
    }
}