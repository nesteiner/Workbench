package com.steiner.workbench.runner

import com.steiner.workbench.clipboard.table.Texts
import com.steiner.workbench.common.util.now
import com.steiner.workbench.daily_attendance.model.*
import com.steiner.workbench.daily_attendance.request.PostTaskRequest
import com.steiner.workbench.todolist.model.Task as tlTask
import com.steiner.workbench.daily_attendance.service.DailyAttendanceService
import com.steiner.workbench.daily_attendance.table.TaskEvents
import com.steiner.workbench.daily_attendance.table.Tasks as daTasks;
import com.steiner.workbench.daily_attendance.table.ImageItems as daImageItems;
import com.steiner.workbench.login.model.Role
import com.steiner.workbench.login.model.User
import com.steiner.workbench.login.service.UserService
import com.steiner.workbench.login.table.Roles
import com.steiner.workbench.login.table.UserRole
import com.steiner.workbench.login.table.Users
import com.steiner.workbench.todolist.model.Tag
import com.steiner.workbench.todolist.model.TaskProject
import com.steiner.workbench.todolist.model.TaskGroup
import com.steiner.workbench.todolist.table.*
import kotlinx.datetime.*
import com.steiner.workbench.todolist.table.Tasks as tlTasks
import com.steiner.workbench.todolist.table.ImageItems as tlImageItems
import org.jetbrains.exposed.sql.SchemaUtils
import org.jetbrains.exposed.sql.batchInsert
import org.jetbrains.exposed.sql.insert
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.ApplicationArguments
import org.springframework.boot.ApplicationRunner
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import kotlin.time.DurationUnit
import kotlin.time.toDuration

@ConditionalOnProperty(name = ["app.initialize"], havingValue = "true")
@Component
@Transactional
class WorkbenchRunner: ApplicationRunner {
    @Autowired
    lateinit var dailyAttendanceService: DailyAttendanceService
    @Autowired
    lateinit var userService: UserService


    override fun run(args: ApplicationArguments?) {
        SchemaUtils.drop(UserRole, TaskEvents, Tags, TaskTag,  SubTasks, daTasks, tlTasks, TaskGroups, tlImageItems, TaskProjects, Texts)
        SchemaUtils.drop(Users, daImageItems, Roles)
        SchemaUtils.create(TaskProjects, TaskGroups, tlTasks, SubTasks, Tags, tlImageItems, TaskTag, Texts)
        SchemaUtils.create(UserRole, Users, daTasks, Roles, TaskEvents, daImageItems)

        val roles = listOf(
            Role(id = 1, name = "admin"),
            Role(id = 2, name = "user")
        )

        roles.forEach { role ->
            Roles.insert {
                it[name] = role.name
            }
        }

        val admin = User(
            id = 1,
            name = "admin",
            passwordHash = "5f4dcc3b5aa765d61d8327deb882cf99",
            roles = listOf(roles[0]),
            enabled = true,
            email = "steiner3044@163.com"
        )

        val steiner = User(
            id = 2,
            name = "steiner",
            passwordHash = "5f4dcc3b5aa765d61d8327deb882cf99",
            roles = listOf(roles[1]),
            enabled = true,
            email = "steiner3044@163.com"
        )

        Users.insert {
            it[name] = admin.name
            it[passwordHash] = admin.passwordHash
            it[enabled] = admin.enabled
            it[email] = admin.email
        }

        Users.insert {
            it[name] = steiner.name
            it[passwordHash] = steiner.passwordHash
            it[enabled] = steiner.enabled
            it[email] = steiner.email
        }

        UserRole.insert {
            it[userid] = admin.id
            it[roleid] = admin.roles[0].id
        }

        UserRole.insert {
            it[userid] = steiner.id
            it[roleid] = steiner.roles[0].id
        }

        tlImageItems.insert {
            it[name] = "default.png"
            it[path] = "/home/steiner/workspace/workbench/storage/todolist/default.png"
        }

        val taskprojects = listOf(
            TaskProject(id = 1, name = "taskproject1", avatarid = 1, index = 1, profile = null, userid = 2, createTime = now(), updateTime = now() + 2.toDuration(
                DurationUnit.SECONDS)),
            TaskProject(id = 2, name = "taskproject2", avatarid = 1, index = 2, profile = null, userid = 2, createTime = now(), updateTime = now() + 1.toDuration(DurationUnit.SECONDS)),
            TaskProject(id = 3, name = "taskproject3", avatarid = 1, index = 3, profile = null, userid = 2, createTime = now(), updateTime = now()),
            TaskProject(id = 4, name = "taskproject4", avatarid = 1, index = 4, profile = null, userid = 2, createTime = now(), updateTime = now()),
        )

        val tasksOfGroup1 = listOf(
            tlTask(id = 1, index = 1, name = "task1", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 1, subtasks = null, tags = null),
            tlTask(id = 2, index = 2, name = "task2", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 1, subtasks = null, tags = null),
            tlTask(id = 3, index = 3, name = "task3", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 1, subtasks = null, tags = null),
            tlTask(id = 4, index = 4, name = "task4", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 1, subtasks = null, tags = null),
            tlTask(id = 5, index = 5, name = "task5", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 1, subtasks = null, tags = null),
        )

        val tasksOfGroup2 = listOf(
            tlTask(id = 6, index = 1, name = "task6", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 7, index = 2, name = "task7", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 8, index = 3, name = "task8", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 9, index = 4, name = "task9", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 10, index = 5, name = "task10", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 11, index = 6, name = "task11", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 12, index = 7, name = "task12", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 13, index = 8, name = "task13", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 14, index = 9, name = "task14", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 15, index = 10, name = "task15", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 16, index = 11, name = "task16", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 17, index = 12, name = "task17", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 18, index = 13, name = "task18", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 19, index = 14, name = "task19", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 20, index = 15, name = "task20", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 21, index = 16, name = "task21", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 22, index = 17, name = "task22", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 23, index = 18, name = "task23", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 24, index = 19, name = "task24", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 25, index = 20, name = "task25", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 26, index = 21, name = "task26", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 27, index = 22, name = "task27", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 28, index = 23, name = "task28", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 29, index = 24, name = "task29", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
            tlTask(id = 30, index = 25, name = "task30", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
        )

        val tasksOfGroup3 = listOf(
            tlTask(id = 31, index = 1, name = "task31", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 3, subtasks = null, tags = null),
            tlTask(id = 32, index = 2, name = "task32", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 3, subtasks = null, tags = null),
            tlTask(id = 33, index = 3, name = "task33", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 3, subtasks = null, tags = null),
            tlTask(id = 34, index = 4, name = "task34", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 3, subtasks = null, tags = null),
            tlTask(id = 35, index = 5, name = "task35", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 3, subtasks = null, tags = null),
        )

        val taskgroups = listOf(
            TaskGroup(id = 1, index = 1, name = "taskgroup1", tasks = tasksOfGroup1, createTime = now(), parentid = 1, updateTime = now()),
            TaskGroup(id = 2, index = 2, name = "taskgroup2", tasks = tasksOfGroup2, createTime = now(), parentid = 1, updateTime = now()),
            TaskGroup(id = 3, index = 3, name = "taskgroup3", tasks = tasksOfGroup3, createTime = now(), parentid = 1, updateTime = now()),
        )

        taskprojects.forEach { taskproject ->
            TaskProjects.insert {
                it[name] = taskproject.name
                it[avatarid] = taskproject.avatarid
                it[createTime] = taskproject.createTime
                it[updateTime] = taskproject.updateTime
                it[index] = taskproject.index
                it[userid] = 2
            }
        }

        taskgroups.forEach { taskgroup ->
            TaskGroups.insert {
                it[index] = taskgroup.index
                it[name] = taskgroup.name
                it[parentid] = taskgroup.parentid
                it[createTime] = taskgroup.createTime
                it[updateTime] = taskgroup.updateTime
            }

            taskgroup.tasks.forEach { task ->
                tlTasks.insert {
                    it[index] = task.index
                    it[name]= task.name
                    it[isdone] = task.isdone
                    it[priority] = task.priority
                    it[parentid] = task.parentid
                    it[createTime] = task.createTime
                    it[updateTime] = task.updateTime
                    it[expectTime] = task.expectTime
                    it[finishTime] = task.finishTime
                    it[deadline] = task.deadline
                    it[notifyTime] = task.notifyTime
                    it[note] = task.note
                }
            }

        }

        val tags = listOf(
            Tag(id = 1, name = "red tag", parentid = 1, color = "#4df44336"),
            Tag(id = 2, name = "blue tag", parentid = 1, color = "#4d2196f3"),
            Tag(id = 3, name = "green tag", parentid = 1, color = "#4d4caf50")
        )

        tags.forEach { tag ->
            Tags.insert {
                it[name] = tag.name
                it[parentid] = tag.parentid
                it[color] = tag.color
            }
        }

        val currentDayLocalDate = LocalDate(2023, 11, 1)

        val requests = listOf<PostTaskRequest>(
            PostTaskRequest(
                name = "背单词",
                encouragement = "学习一门语言当然要背单词啦",
                frequency = Frequency.Interval(2),
                goal = Goal.Amount(5, "页", 1),
                group = Group.Afternoon,
                icon = Icon.Word(char = '你', color = "#4295f5"),
                keepdays = KeepDays.Forever,
                startTime = currentDayLocalDate,
                notifyTimes = arrayOf(NotifyTime(13, 0)),
                userid = userService.findOne("steiner")!!.id
            ),

            PostTaskRequest(
                name = "阅读",
                encouragement = "有空看看书，说不定会有新收获",
                frequency = Frequency.Days(arrayOf(DayOfWeek.MONDAY, DayOfWeek.TUESDAY, DayOfWeek.WEDNESDAY, DayOfWeek.THURSDAY, DayOfWeek.FRIDAY, DayOfWeek.SATURDAY, DayOfWeek.SUNDAY)),
                goal = Goal.CurrentDay,
                group = Group.Night,
                icon = Icon.Word(char = '好', color = "#f54293"),
                keepdays = KeepDays.Forever,
                startTime = currentDayLocalDate.plus(1, DateTimeUnit.DAY),
                notifyTimes = arrayOf(NotifyTime(20, 0)),
                userid = userService.findOne("steiner")!!.id
            ),

            PostTaskRequest(
                name = "吃水果",
                encouragement = "饭后来电水果就更棒了",
                frequency = Frequency.CountInWeek(2),
                goal = Goal.CurrentDay,
                group = Group.Other,
                icon = Icon.Word(char = '世', color = "#78f542"),
                keepdays = KeepDays.Forever,
                startTime = currentDayLocalDate.plus(2, DateTimeUnit.DAY),
                notifyTimes = arrayOf(),
                userid = userService.findOne("steiner")!!.id
            ),

            PostTaskRequest(
                name = "吃药",
                encouragement = "别忘了按时吃药",
                frequency = Frequency.CountInWeek(2),
                goal = Goal.CurrentDay,
                group = Group.Other,
                icon = Icon.Word(char = '界', color = "#3742fa"),
                keepdays = KeepDays.Forever,
                startTime = currentDayLocalDate.plus(2, DateTimeUnit.DAY),
                notifyTimes = arrayOf(),
                userid = userService.findOne("steiner")!!.id
            ),
        )

        requests.forEach {
            dailyAttendanceService.insertOne(it)
        }
    }


}