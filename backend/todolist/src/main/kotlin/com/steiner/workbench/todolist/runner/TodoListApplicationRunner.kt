package com.steiner.workbench.todolist.runner

import com.steiner.workbench.login.model.Role
import com.steiner.workbench.login.model.User
import com.steiner.workbench.login.table.Roles
import com.steiner.workbench.login.table.UserRole
import com.steiner.workbench.login.table.Users
import com.steiner.workbench.todolist.model.Tag
import com.steiner.workbench.todolist.model.Task
import com.steiner.workbench.todolist.model.TaskGroup
import com.steiner.workbench.todolist.model.TaskProject
import com.steiner.workbench.todolist.table.*
import com.steiner.workbench.todolist.util.now
import org.jetbrains.exposed.sql.*
import org.springframework.boot.ApplicationArguments
import org.springframework.boot.ApplicationRunner
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import kotlin.time.Duration
import kotlin.time.DurationUnit
import kotlin.time.toDuration

@Component
@Transactional
class TodoListApplicationRunner: ApplicationRunner {
    override fun run(args: ApplicationArguments?) {
        SchemaUtils.drop(TaskTag, Tags, SubTasks, Tasks, TaskGroups, TaskProjects, ImageItems)
        SchemaUtils.drop(UserRole, Users, Roles)
        SchemaUtils.create(UserRole, Users, Roles)
        SchemaUtils.create(TaskProjects, TaskGroups, Tasks, SubTasks, Tags, ImageItems, TaskTag)

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

        ImageItems.insert {
            it[name] = "default.png"
            it[path] = "/home/steiner/workspace/workbench/storage/default.png"
        }

        val taskprojects = listOf(
                TaskProject(id = 1, name = "taskproject1", avatarid = 1, index = 1, profile = null, userid = 2, createTime = now(), updateTime = now() + 2.toDuration(DurationUnit.SECONDS)),
                TaskProject(id = 2, name = "taskproject2", avatarid = 1, index = 2, profile = null, userid = 2, createTime = now(), updateTime = now() + 1.toDuration(DurationUnit.SECONDS)),
                TaskProject(id = 3, name = "taskproject3", avatarid = 1, index = 3, profile = null, userid = 2, createTime = now(), updateTime = now()),
                TaskProject(id = 4, name = "taskproject4", avatarid = 1, index = 4, profile = null, userid = 2, createTime = now(), updateTime = now()),
        )

        val tasksOfGroup1 = listOf(
                Task(id = 1, index = 1, name = "task1", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 1, subtasks = null, tags = null),
                Task(id = 2, index = 2, name = "task2", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 1, subtasks = null, tags = null),
                Task(id = 3, index = 3, name = "task3", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 1, subtasks = null, tags = null),
                Task(id = 4, index = 4, name = "task4", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 1, subtasks = null, tags = null),
                Task(id = 5, index = 5, name = "task5", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 1, subtasks = null, tags = null),
        )

        val tasksOfGroup2 = listOf(
                Task(id = 6, index = 1, name = "task6", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 7, index = 2, name = "task7", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 8, index = 3, name = "task8", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 9, index = 4, name = "task9", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 10, index = 5, name = "task10", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 11, index = 6, name = "task11", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 12, index = 7, name = "task12", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 13, index = 8, name = "task13", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 14, index = 9, name = "task14", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 15, index = 10, name = "task15", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 16, index = 11, name = "task16", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 17, index = 12, name = "task17", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 18, index = 13, name = "task18", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 19, index = 14, name = "task19", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 20, index = 15, name = "task20", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 21, index = 16, name = "task21", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 22, index = 17, name = "task22", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 23, index = 18, name = "task23", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 24, index = 19, name = "task24", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 25, index = 20, name = "task25", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 26, index = 21, name = "task26", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 27, index = 22, name = "task27", isdone = false, priority = 0, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 28, index = 23, name = "task28", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 29, index = 24, name = "task29", isdone = false, priority = 2, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
                Task(id = 30, index = 25, name = "task30", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 2, subtasks = null, tags = null),
        )

        val tasksOfGroup3 = listOf(
                Task(id = 31, index = 1, name = "task31", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 3, subtasks = null, tags = null),
                Task(id = 32, index = 2, name = "task32", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 3, subtasks = null, tags = null),
                Task(id = 33, index = 3, name = "task33", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 3, subtasks = null, tags = null),
                Task(id = 34, index = 4, name = "task34", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 3, subtasks = null, tags = null),
                Task(id = 35, index = 5, name = "task35", isdone = false, priority = 1, createTime = now(), updateTime = now(), deadline = null, notifyTime = null, expectTime = 4, finishTime = 0, note = null, parentid = 3, subtasks = null, tags = null),
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
                Tasks.insert {
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
    }

}