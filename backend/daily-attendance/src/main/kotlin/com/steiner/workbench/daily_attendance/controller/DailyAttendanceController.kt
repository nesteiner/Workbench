package com.steiner.workbench.daily_attendance.controller

import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.common.util.Response
import com.steiner.workbench.daily_attendance.model.*
import com.steiner.workbench.daily_attendance.request.PostTaskRequest
import com.steiner.workbench.daily_attendance.request.UpdateArchiveTaskRequest
import com.steiner.workbench.daily_attendance.request.UpdateProgressRequest
import com.steiner.workbench.daily_attendance.request.UpdateTaskRequest
import com.steiner.workbench.daily_attendance.service.DailyAttendanceService
import com.steiner.workbench.login.service.UserService
import jakarta.validation.Valid
import kotlinx.datetime.DayOfWeek
import kotlinx.datetime.LocalDate
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.validation.BindingResult
import org.springframework.validation.annotation.Validated
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController


/// if use you Response, there must be Response.Ok or Response.Err,
/// because Response has not been serialized by kotlinx.serialization
/// but its derived types are
@RestController
@RequestMapping("/daily-attendance")
@Validated
class DailyAttendanceController {
    @Autowired
    lateinit var dailyAttendanceService: DailyAttendanceService
    @Autowired
    lateinit var userService: UserService
    @PostMapping
    fun insertOne(@RequestBody @Valid request: PostTaskRequest, bindingResult: BindingResult): Response.Ok<Task> {
        return Response.Ok(
                "insert ok",
                dailyAttendanceService.insertOne(request)
        )
    }

    @PutMapping
    fun updateOne(@RequestBody @Valid request: UpdateTaskRequest, bindingResult: BindingResult): Response.Ok<Task> {
        return Response.Ok(
                "update ok",
                dailyAttendanceService.updateOne(request)
        )
    }

    @PutMapping("/progress")
    fun updateOne(@RequestBody request: UpdateProgressRequest): Response.Ok<Task> {
        return Response.Ok(
                "update ok",
                dailyAttendanceService.updateProgress(request)
        )
    }


    @PutMapping("/archive")
    fun updateArchiveOne(@RequestBody request: UpdateArchiveTaskRequest): Response.Ok<Unit> {
        dailyAttendanceService.updateArchive(request)
        return Response.Ok("update archive ok", Unit)
    }
    @DeleteMapping("/{id}")
    fun deleteOne(@PathVariable("id") id: Int): Response.Ok<Unit> {
        dailyAttendanceService.deleteOne(id)
        return Response.Ok("delete ok", Unit)
    }

    @GetMapping("/current-day")
    fun findAllOfCurrentDay(): Response.Ok<List<Task>> {
        val userid = userService.currentUserId()
        return Response.Ok("all daily attendance", dailyAttendanceService.findAll(userid))
    }

    @GetMapping("/current-7")
    fun findAllOfLatest7Days(): Response.Ok<Map<DayOfWeek, List<Task>>> {
        val userid = userService.currentUserId()
        return Response.Ok("all daily attendance", dailyAttendanceService.findLatest7Days(userid))
    }

    @GetMapping("/{id}")
    fun findOne(@PathVariable("id") id: Int): Response.Ok<Task> {
        val item = dailyAttendanceService.findOne(id) ?: throw BadRequestException("no such daily atatendance")
        return Response.Ok("this daily attendance", item)
    }

    @PutMapping("/reset/{id}")
    fun resetToday(@PathVariable("id") id: Int): Response.Ok<Unit> {
        dailyAttendanceService.resetTaskCurrentDay(id)
        return Response.Ok("reset ok", Unit)
    }
}