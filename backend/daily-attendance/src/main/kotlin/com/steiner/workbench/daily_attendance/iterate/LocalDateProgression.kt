package com.steiner.workbench.daily_attendance.iterate

import kotlinx.datetime.LocalDate
import kotlin.collections.Iterator

class LocalDateProgression(
        override val start: LocalDate,
        override val endInclusive: LocalDate,
        val days: Int = 1
): Iterable<LocalDate>, ClosedRange<LocalDate> {

    override fun iterator(): Iterator<LocalDate> {
        return LocalDateIterator(start, endInclusive, days)
    }

    infix fun step(days: Int) = LocalDateProgression(start, endInclusive, days)
}

operator fun LocalDate.rangeTo(other: LocalDate) = LocalDateProgression(this, other)