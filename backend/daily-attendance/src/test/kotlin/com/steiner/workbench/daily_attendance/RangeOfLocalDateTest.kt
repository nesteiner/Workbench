package com.steiner.workbench.daily_attendance

import kotlinx.datetime.LocalDate
import org.junit.jupiter.api.Test
import com.steiner.workbench.daily_attendance.iterate.*
import kotlinx.datetime.DatePeriod
import kotlinx.datetime.plus

class RangeOfLocalDateTest {
    @Test
    fun testRange() {
        val start = LocalDate(2023, 11, 1)
        val end = LocalDate(2023, 11, 12)
        var count = 1
        for (element in start..end step 1) {
            if (count >= 100) {
                break
            }

            println(element)

            count += 1
        }
    }
}


