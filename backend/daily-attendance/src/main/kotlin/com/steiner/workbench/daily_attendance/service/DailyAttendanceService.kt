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
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import kotlin.math.abs
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

        val logger: Logger = LoggerFactory.getLogger(DailyAttendanceService::class.java)
    }

    fun insertOne(request: PostTaskRequest): Task {
        val ifexists = Tasks.select(Tasks.name eq request.name.trim()).firstOrNull()
        if (ifexists != null) {
            throw BadRequestException("there is already a task named ${request.name}")
        }
        val id = Tasks.insert {
            it[name] = request.name
            it[icon] = request.icon
            it[encouragement] = request.encouragement
            it[frequency] = request.frequency
            it[goal] = request.goal
            it[startTime] = request.startTime
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
        val yesterday = (now0 - 1.toDuration(DurationUnit.DAYS)).toLocalDateTime(CURRENT_TIME_ZONE).date
        Tasks.slice(Tasks.id, Tasks.name, Tasks.consecutiveDays, Tasks.persistenceDays)
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

                    val op = with (TaskEvents) {
                        (taskid eq taskid0) and
                                (time.year() eq yesterday.year) and
                                (time.month() eq yesterday.monthNumber) and
                                (time.day() eq yesterday.dayOfMonth)
                    }

                    val yesterdayProgress = TaskEvents
                        .slice(TaskEvents.progress)
                        .select(op)
                        .firstOrNull()?.let {
                            it[TaskEvents.progress]
                        }

                    var cday = it[Tasks.consecutiveDays]
                    var pday = it[Tasks.persistenceDays]

                    if (yesterdayProgress != null) {
                        if (yesterdayProgress is Progress.Done && progress0 is Progress.Done) {
                            cday += 1
                            pday += 1
                        } else {
                            cday = 0
                        }
                    } else {
                        if (progress0 is Progress.Done) {
                            cday = 1
                            pday += 1
                        } else {
                            cday = 0
                        }
                    }

                    Tasks.update({ Tasks.id eq taskid0 }) {
                        it[consecutiveDays] = cday
                        it[persistenceDays] = pday
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

    /// findAll tasks which userid = userid, at the date of `localdate`
    /// this is like history of tasks
    fun findAll(localdate: LocalDate, userid: Int): List<Task> {
        return Tasks
                .select(
                        (Tasks.isarchived eq false)
                                and
                                (Tasks.startTime lessEq localdate)
                                and
                                (Tasks.userid eq userid)
                ).filter {
                    when (val keepdays = it[Tasks.keepdays]) {
                        is KeepDays.Forever -> true

                        is KeepDays.Manual -> {
                            val days = keepdays.days
                            val startTime = it[Tasks.startTime]
                            val endTime = startTime.plus(days, DateTimeUnit.DAY)

                            endTime >= localdate
                        }
                    }
                }.map {
                val taskEvents = findAllEventsUntilThisWeek(it[Tasks.id].value, localdate)
                // val lastProgress = taskEvents.lastOrNull()?.progress ?: Progress.Ready
                val lastProgress = taskEvents.lastOrNull { event ->
                    val time = event.time.toLocalDateTime(TimeZone.of("Asia/Shanghai"))
                    time.run {
                        year == localdate.year &&
                                month == localdate.month &&
                                dayOfMonth == localdate.dayOfMonth
                    }
                }?.progress ?: Progress.Ready

                // STUB
                // val name0 = it[Tasks.name]
                // logger.info("$localdate - $name0: $lastProgress")
                val progress = when (val frequency = it[Tasks.frequency]) {
                    is Frequency.Days -> {
                        if (frequency.weekdays.contains(localdate.dayOfWeek)) {
                            lastProgress
                        } else {
                            Progress.NotScheduled
                        }
                    }

                    is Frequency.CountInWeek -> {
                        val count = taskEvents.count { taskevent ->
                            taskevent.progress == Progress.Done
                        }

                        if (count >= frequency.count) {
                            Progress.Done
                        } else {
                            lastProgress
                        }
                    }

                    is Frequency.Interval -> {
                        val lastEvent = findLastEventsUntilThisDay(it[Tasks.id].value, localdate)
                        val lastDate = lastEvent?.time?.toLocalDateTime(CURRENT_TIME_ZONE)?.date
                        val isScheduled: Boolean = if (lastDate != null) {
                            // isSameDay(lastDate.plus(frequency.count, DateTimeUnit.DAY), localdate)
                            (lastDate..localdate step frequency.count).count { date ->
                                isSameDay(date, localdate)
                            } > 0
                        } else {
                            (it[Tasks.startTime]..localdate step frequency.count).count { date ->
                                isSameDay(date, localdate)
                            } > 0
                        }

                        if (isScheduled) {
                            lastProgress
                        } else {
                            Progress.NotScheduled
                        }
                    }
                }

                with (Tasks) {
                    Task(
                        id = it[id].value,
                        name = it[name],
                        icon = it[icon],
                        encouragement = it[encouragement],
                        frequency = it[frequency],
                        goal = it[goal],
                        startTime = it[startTime],
                        keepdays = it[keepdays],
                        group = it[group],
                        notifyTimes = it[notifyTimes],
                        progress = progress,
                        isarchived = it[isarchived],
                        userid = it[Tasks.userid].value,
                        consecutiveDays = it[consecutiveDays],
                        persistenceDays = it[persistenceDays]
                    )
                }
            }
    }

    fun findLatest7Days(userid: Int): Map<DayOfWeek, List<Task>> {
        val currentDay = now()
        val currentDayLocalDate = currentDay.toLocalDateTime(CURRENT_TIME_ZONE).date
        val past6LocalDate = currentDay.minus(6.toDuration(DurationUnit.DAYS)).toLocalDateTime(CURRENT_TIME_ZONE).date

        val result = HashMap<DayOfWeek, List<Task>>()

        (past6LocalDate..currentDayLocalDate).forEach {
            val value = findAll(it, userid)
            val key = it.dayOfWeek

            result[key] = value
        }

        return result
    }

    fun refreshDataDaily() {
        // this should be called once a day
        // given a now instant, refresh progress by frequency and former progress
        val currentDay = now()
        val currentDayLocalDate = currentDay.toLocalDateTime(CURRENT_TIME_ZONE).date

        Tasks.select((Tasks.isarchived eq false) and (Tasks.startTime lessEq currentDayLocalDate))
                .filter {
                    when (val keepdays = it[Tasks.keepdays]) {
                        is KeepDays.Forever -> true
                        is KeepDays.Manual -> {
                            val startTime = it[Tasks.startTime]
                            val endTime = startTime.plus(keepdays.days, DateTimeUnit.DAY)

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

                            if (doneCount >= count) {
                                Tasks.update({ Tasks.id eq id }) {
                                    it[progress] = Progress.NotScheduled
                                }
                            }
                        }

                        is Frequency.Interval -> {
                            val taskEvent = findLastEventsUntilThisDay(it[Tasks.id].value, currentDayLocalDate)
                            val startTime = it[Tasks.startTime]
                            val lastDate = taskEvent?.time?.toLocalDateTime(CURRENT_TIME_ZONE)?.date

                            val isScheduled: Boolean  = if (lastDate != null) {
                                isSameDay(lastDate.plus(frequency.count, DateTimeUnit.DAY), currentDayLocalDate)
                            } else {
                                (startTime..currentDayLocalDate step frequency.count).count { date ->
                                    isSameDay(date, currentDayLocalDate)
                                } > 0
                            }

                            Tasks.update({ Tasks.id eq id }) {
                                it[progress] = if (isScheduled) {
                                    Progress.Ready
                                } else {
                                    Progress.NotScheduled
                                }
                            }

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
        val endOfWeek = startOfWeek + 6.toDuration(DurationUnit.DAYS)

        return with (TaskEvents) {
            select(
                (TaskEvents.taskid eq taskid) and
                        (time greaterEq startOfWeek) and
                        (time lessEq endOfWeek)
            ).map {
                TaskEvent(
                    id = it[id].value,
                    taskid = it[TaskEvents.taskid].value,
                    taskname = it[taskname],
                    time = it[time],
                    progress = it[progress]
                )
            }
        }
    }

    /// task events: start of week to localdate
    fun findAllEventsUntilThisWeek(taskid: Int, localdate: LocalDate): List<TaskEvent> {
        val distance = dayDistance[localdate.dayOfWeek]!!
        val startOfWeek = localdate.minus(distance, DateTimeUnit.DAY)

        return with (TaskEvents) {
            val op = (TaskEvents.taskid eq taskid) and
                    (time.year() greaterEq startOfWeek.year) and
                    (time.month() greaterEq startOfWeek.monthNumber) and
                    (time.day() greaterEq startOfWeek.dayOfMonth) and
                    (time.year() lessEq localdate.year) and
                    (time.month() lessEq localdate.monthNumber) and
                    (time.day() lessEq localdate.dayOfMonth)

            select(op).map {
                TaskEvent(
                    id = it[id].value,
                    taskid = it[TaskEvents.taskid].value,
                    taskname = it[taskname],
                    time = it[time],
                    progress = it[progress]
                )
            }
        }
    }

    fun findLastEventsUntilThisDay(taskid: Int, localdate: LocalDate): TaskEvent? {
        return with (TaskEvents) {
            val op = (TaskEvents.taskid eq taskid) and
                    (time.year() lessEq localdate.year) and
                    (time.month() lessEq localdate.monthNumber) and
                    (time.day() lessEq localdate.dayOfMonth)

            select(op).lastOrNull()?.let {
                TaskEvent(
                    id = it[id].value,
                    taskid = it[TaskEvents.taskid].value,
                    taskname = it[taskname],
                    time = it[time],
                    progress = it[progress]
                )
            }
        }
    }

    fun resetTaskCurrentDay(id: Int): Task {
        val currentDay = now()
        val currentDayLocalDate = currentDay.toLocalDateTime(CURRENT_TIME_ZONE).date
        val (progress1, cday, pday) = with (Tasks) {
            slice(progress, consecutiveDays, persistenceDays)
                .select(Tasks.id eq id)
                .first()
                .let {
                    listOf(it[progress], it[consecutiveDays], it[persistenceDays])
                }
        }

        if (progress1 is Progress.Done) {
            if (cday != 0) {
                with (Tasks) {
                    update({ Tasks.id eq id }) {
                        with (SqlExpressionBuilder) {
                            it.update(consecutiveDays, consecutiveDays - 1)
                        }
                    }
                }
            }

            if (pday != 0) {
                with (Tasks) {
                    update({ Tasks.id eq id }) {
                        with (SqlExpressionBuilder) {
                            it.update(persistenceDays, persistenceDays - 1)
                        }
                    }
                }
            }
        }

        Tasks.update({ Tasks.id eq id }) {
            it[progress] = Progress.Ready
        }

        TaskEvents.deleteWhere {
            val r0 = TaskEvents.taskid eq id
            val r1 = time.year() eq currentDayLocalDate.year
            val r2 = time.month() eq currentDayLocalDate.monthNumber
            val r3 = time.day() eq currentDayLocalDate.dayOfMonth

            r0 and r1 and r2 and r3
        }

        return findOne(id)!!
    }

    /**
     * @param offset: 距离本周的偏移量, it should be negative
     */
    fun statisticsThisWeek(offset: Int, userid: Int): Map<Int, Map<DayOfWeek, Progress>> {
        assert(offset < 0)

        val now = now()
        val nowLocalDate = now.toLocalDateTime(CURRENT_TIME_ZONE).date
        val distance = dayDistance[nowLocalDate.dayOfWeek]!!
        val startOfWeek = nowLocalDate.minus(distance, DateTimeUnit.DAY)
        val startOfThisWeek = startOfWeek.minus(abs(offset), DateTimeUnit.WEEK)
        val endOfThisWeek = startOfThisWeek.plus(6, DateTimeUnit.DAY)

        val progressRecord = mutableMapOf<Int, MutableMap<DayOfWeek, Progress>>()

        (startOfThisWeek..endOfThisWeek).forEach { date ->
            val tasks = findAll(date, userid)
            for (task in tasks) {
                if (progressRecord.containsKey(task.id)) {
                    // result[task.id]?.add(task.progress)
                    progressRecord[task.id]!![date.dayOfWeek] = task.progress
                } else {
                    // result[task.id] = mutableListOf(task.progress)
                    progressRecord[task.id] = mutableMapOf(date.dayOfWeek to task.progress)
                }
            }

        }

        return progressRecord
    }

    /**
     * @param offset: 距离本月的偏移量, it should be negative
     */
    fun statisticsThisMonth(offset: Int, userid: Int): Map<Int, Map<Int, Progress>> {
        assert(offset < 0)

        val now = now()
        val nowLocalDate = now.toLocalDateTime(CURRENT_TIME_ZONE).date
        val startOfMonth = LocalDate(nowLocalDate.year, nowLocalDate.monthNumber, 1)
        val thisMonth = startOfMonth.minus(abs(offset), DateTimeUnit.MONTH)
        val endOfMonth = thisMonth.plus(DatePeriod(months = 1)).minus(1, DateTimeUnit.DAY)

        val progressRecord = mutableMapOf<Int, MutableMap<Int, Progress>>()
        (thisMonth..endOfMonth).forEach { date ->
            val tasks = findAll(date, userid)
            for (task in tasks) {
                if (progressRecord.containsKey(task.id)) {
                    // result[task.id]?.add(task.progress)
                    progressRecord[task.id]?.put(date.dayOfMonth, task.progress)
                } else {
                    // result[task.id] = mutableListOf(task.progress)
                    progressRecord[task.id] = mutableMapOf(date.dayOfMonth to task.progress)
                }
            }
        }

        return progressRecord
    }

    /// this is for management
    fun findAllAvailable(userid: Int, isarchive: Boolean): List<Task> {
        return with (Tasks) {
            select((this.userid eq userid) and (this.isarchived eq isarchive))
                .map {
                    findOne(it[id].value)!!
                }
        }
    }
    
    private fun isSameDay(left: LocalDate, right: LocalDate): Boolean {
        return left.year == right.year && left.month == right.month && left.dayOfMonth == right.dayOfMonth
    }
}