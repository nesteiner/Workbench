package com.steiner.workbench.todolist.util

import kotlinx.datetime.Clock
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toInstant
import kotlinx.datetime.toLocalDateTime

private val timezone = TimeZone.currentSystemDefault()
fun now() = Clock.System.now().toLocalDateTime(timezone).toInstant(TimeZone.UTC)