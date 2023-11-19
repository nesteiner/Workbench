package com.steiner.workbench.daily_attendance.iterate

import kotlinx.datetime.DatePeriod
import kotlinx.datetime.LocalDate
import kotlinx.datetime.plus

class LocalDateIterator(
        val startDate: LocalDate,
        val endDate: LocalDate,
        val days: Int): Iterator<LocalDate> {

    private var currentDate = startDate

    override fun hasNext(): Boolean {
        return currentDate <= endDate
    }

    override fun next(): LocalDate {
        val next = currentDate
        currentDate = currentDate.plus(DatePeriod(days = days))
        return next
    }
}