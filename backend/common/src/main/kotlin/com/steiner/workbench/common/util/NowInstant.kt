package com.steiner.workbench.common.util

import kotlinx.datetime.*

val CURRENT_TIME_ZONE = TimeZone.of("Asia/Shanghai")
private val ASIA_TIME_ZONE = TimeZone.of("Asia/Shanghai")
fun shanghaiNow() = Clock.System.now().toLocalDateTime(CURRENT_TIME_ZONE).toInstant(UtcOffset(hours = 8))
// fun shanghaiNow() = Instant.fromEpochMilliseconds(System.currentTimeMillis()) + 8.toDuration(DurationUnit.HOURS)
