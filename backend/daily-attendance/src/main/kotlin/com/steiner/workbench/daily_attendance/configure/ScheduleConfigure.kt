package com.steiner.workbench.daily_attendance.configure

import com.steiner.workbench.common.util.shanghaiNow
import com.steiner.workbench.daily_attendance.service.DailyAttendanceService
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.annotation.Configuration
import org.springframework.scheduling.annotation.EnableScheduling
import org.springframework.scheduling.annotation.Scheduled

@EnableScheduling
@Configuration
class ScheduleConfigure {
    companion object {
        val logger: Logger = LoggerFactory.getLogger(ScheduleConfigure::class.java)
    }

    @Autowired
    lateinit var dailyAttendanceService: DailyAttendanceService

    /// 每天凌晨12点刷新一次状态
    @Scheduled(cron = "0 0 0 * * *", zone = "Asia/Shanghai")
    fun refreshTasks() {
        dailyAttendanceService.refreshDataDaily()
    }
}