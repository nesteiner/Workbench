package com.steiner.workbench.daily_attendance.model

import kotlinx.serialization.Serializable

@Serializable
class NotifyTime(val hour: Int, val minute: Int)