package com.steiner.workbench.daily_attendance.iterate

import kotlinx.datetime.LocalDate
import kotlin.collections.Iterator

class LocalDateWithSingleDayProgression(
        override val start: LocalDate,
        override val endInclusive: LocalDate,
        val step: Int = 1
): Iterable<LocalDate>, ClosedRange<LocalDate> {

    override fun iterator(): Iterator<LocalDate> {
        return LocalDateIterator(start, endInclusive, step)
    }

    infix fun step(days: Int) = LocalDateWithSingleDayProgression(start, endInclusive, days)
}

operator fun LocalDate.rangeTo(other: LocalDate) = LocalDateWithSingleDayProgression(this, other)