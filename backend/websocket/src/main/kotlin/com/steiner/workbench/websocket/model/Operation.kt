package com.steiner.workbench.websocket.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class Operation {
    @Serializable
    @SerialName("TaskProject:Post")
    object TaskProjectPost: Operation()

    @Serializable
    @SerialName("TaskProject:Delete")
    class TaskProjectDelete(val id: Int): Operation()

    @Serializable
    @SerialName("TaskProject:Update")
    class TaskProjectUpdate(val id: Int): Operation()

    @Serializable
    @SerialName("TaskGroup:Post")
    class TaskGroupPost(val taskprojectId: Int): Operation()

    @Serializable
    @SerialName("TaskGroup:Delete")
    class TaskGroupDelete(val taskprojectId: Int, val id: Int): Operation()


    @Serializable
    @SerialName("TaskGroup:Update")
    class TaskGroupUpdate(val taskprojectId: Int, val id: Int): Operation()

    @Serializable
    @SerialName("Task:Post")
    class TaskPost(val taskprojectId: Int, val taskgroupId: Int, val id: Int): Operation()

    @Serializable
    @SerialName("Task:Delete")
    class TaskDelete(val taskprojectId: Int, val taskgroupId: Int, val id: Int): Operation()

    @Serializable
    @SerialName("Task:Update")
    class TaskUpdate(val taskprojectid: Int, val taskgroupId: Int, val id: Int): Operation()

    @Serializable
    @SerialName("DailyAttendance:Post")
    object DailyAttendancePost: Operation()

    @Serializable
    @SerialName("DailyAttendance:Delete")
    class DailyAttendanceDelete(val id: Int): Operation()

    @Serializable
    @SerialName("DailyAttendance:Update")
    class DailyAttendanceUpdate(val id: Int): Operation()

    @Serializable
    @SerialName("Clipboard:Post")
    object ClipboardPost: Operation()

    @Serializable
    @SerialName("Clipboard:Delete")
    class ClipboardDelete(val id: Int): Operation()

    @Serializable
    @SerialName("Samba:Update")
    class SambaUpdate(val parentPath: String): Operation()
}