package com.steiner.workbench.daily_attendance

import com.steiner.workbench.common.util.CURRENT_TIME_ZONE
import com.steiner.workbench.common.util.now
import kotlinx.datetime.toLocalDateTime
import org.junit.jupiter.api.Test
import kotlin.time.DurationUnit
import kotlin.time.toDuration
import com.steiner.workbench.daily_attendance.iterate.rangeTo
class Latest7DayTest {
    @Test
    fun `test latest 7 day`() {
        val currentDay = now()
        val currentDayLocalDate = currentDay.toLocalDateTime(CURRENT_TIME_ZONE).date
        val past6Local = currentDay.minus(6.toDuration(DurationUnit.DAYS))
        val past6LocalDate = past6Local.toLocalDateTime(CURRENT_TIME_ZONE).date

        println("now is $currentDay")
        println("current day localdate is $currentDayLocalDate")
        println("day of week is ${currentDayLocalDate.dayOfWeek}")
        println("past6local is $past6Local")
        for (date in past6LocalDate..currentDayLocalDate) {
            println(date.dayOfWeek)
        }
    }
}