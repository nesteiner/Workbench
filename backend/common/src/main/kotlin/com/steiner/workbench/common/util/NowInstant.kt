package com.steiner.workbench.common.util

import kotlinx.datetime.Clock
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toInstant
import kotlinx.datetime.toLocalDateTime

val CURRENT_TIME_ZONE = TimeZone.currentSystemDefault()
fun now() = Clock.System.now().toLocalDateTime(CURRENT_TIME_ZONE).toInstant(TimeZone.UTC)