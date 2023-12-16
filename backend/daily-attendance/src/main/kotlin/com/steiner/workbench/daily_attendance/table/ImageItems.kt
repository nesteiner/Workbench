package com.steiner.workbench.daily_attendance.table

import com.steiner.workbench.common.DAILY_ATTENDANCE_IMAGE_PATH_LENGTH
import com.steiner.workbench.common.DAILY_ATTENDANCE_NAME_LENGTH
import org.jetbrains.exposed.dao.id.IntIdTable

object ImageItems: IntIdTable("daily-attendance-imageitems") {
    val name = varchar("name", DAILY_ATTENDANCE_NAME_LENGTH)
    val path = varchar("path", DAILY_ATTENDANCE_IMAGE_PATH_LENGTH)
}