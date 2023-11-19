package com.steiner.workbench.daily_attendance.model

import kotlinx.datetime.Instant

class TaskEvent(
        val id: Int,
        val taskname: String,
        val taskid: Int,
        val time: Instant,
        val progress: Progress
)