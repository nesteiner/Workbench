package com.steiner.workbench.common.util

import kotlinx.datetime.*

val CURRENT_TIME_ZONE = TimeZone.UTC
fun now(): Instant = Clock.System.now()