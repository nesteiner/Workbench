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
import com.steiner.workbench.websocket.endpoint.WebSocketEndpoint
import com.steiner.workbench.websocket.model.Operation
import jakarta.validation.Valid
import kotlinx.datetime.DayOfWeek
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
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController


/// if you use Response, there must be Response.Ok or Response.Err,
/// because Response has not been serialized by kotlinx.serialization
/// but its derived types are
@RestController
@RequestMapping("/{uid}/daily-attendance")
@Validated
class DailyAttendanceController {
    @Autowired
    lateinit var dailyAttendanceService: DailyAttendanceService
    @Autowired
    lateinit var userService: UserService
    @Autowired
    lateinit var websocket: WebSocketEndpoint

    @PostMapping
    fun insertOne(@RequestBody @Valid request: PostTaskRequest, bindingResult: BindingResult, @PathVariable("uid") uid: String): Response.Ok<Task> {
        val result = dailyAttendanceService.insertOne(request)
        WebSocketEndpoint.notifyAll(uid, Operation.DailyAttendancePost)

        return Response.Ok(
                "insert ok",
                result
        )
    }

    @PutMapping
    fun updateOne(@RequestBody @Valid request: UpdateTaskRequest, bindingResult: BindingResult, @PathVariable("uid") uid: String): Response.Ok<Task> {
        val result = dailyAttendanceService.updateOne(request)
        WebSocketEndpoint.notifyAll(uid, Operation.DailyAttendanceUpdate(request.id))

        return Response.Ok(
                "update ok",
                result
        )
    }

    @PutMapping("/progress")
    fun updateOne(@RequestBody request: UpdateProgressRequest, @PathVariable("uid") uid: String): Response.Ok<Task> {
        val result = dailyAttendanceService.updateProgress(request)
        WebSocketEndpoint.notifyAll(uid, Operation.DailyAttendanceUpdate(request.id))

        return Response.Ok(
                "update ok",
                result
        )
    }


    @PutMapping("/archive")
    fun updateArchiveOne(@RequestBody request: UpdateArchiveTaskRequest, @PathVariable("uid") uid: String): Response.Ok<Unit> {
        dailyAttendanceService.updateArchive(request)
        WebSocketEndpoint.notifyAll(uid, Operation.DailyAttendanceUpdate(request.id))
        return Response.Ok("update archive ok", Unit)
    }
    @DeleteMapping("/{id}")
    fun deleteOne(@PathVariable("id") id: Int, @PathVariable("uid") uid: String): Response.Ok<Unit> {
        dailyAttendanceService.deleteOne(id)
        WebSocketEndpoint.notifyAll(uid, Operation.DailyAttendanceDelete(id))
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
        val item = dailyAttendanceService.findOne(id) ?: throw BadRequestException("no such daily attendance")
        return Response.Ok("this daily attendance", item)
    }

    @GetMapping(params = ["archive"])
    fun findAll(@RequestParam("archive") archive: Boolean): Response.Ok<List<Task>> {
        val userid = userService.currentUserId()
        val list = dailyAttendanceService.findAllAvailable(userid, archive)
        return Response.Ok("all available", list)
    }

    @PutMapping("/reset/{id}")
    fun resetToday(@PathVariable("id") id: Int, @PathVariable("uid") uid: String): Response.Ok<Task> {
        val result = dailyAttendanceService.resetTaskCurrentDay(id)
        WebSocketEndpoint.notifyAll(uid, Operation.DailyAttendanceUpdate(id))
        return Response.Ok("reset ok", result)
    }

    @GetMapping("/statistics/week", params = ["offset"])
    fun statisticsWeekly(@RequestParam("offset") offset: Int): Response.Ok<Map<Int, Map<DayOfWeek, Progress>>> {
        val userid = userService.currentUserId()
        return Response.Ok(
            "statistics weekly",
            dailyAttendanceService.statisticsThisWeek(offset, userid)
        )
    }

    @GetMapping("/statistics/month", params = ["offset"])
    fun statisticsMonthly(@RequestParam("offset") offset: Int): Response.Ok<Map<Int, Map<Int, Progress>>> {
        val userid = userService.currentUserId()
        return Response.Ok(
            "statistics monthly",
            dailyAttendanceService.statisticsThisMonth(offset, userid)
        )
    }
}