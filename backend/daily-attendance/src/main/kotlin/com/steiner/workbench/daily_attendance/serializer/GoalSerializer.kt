package com.steiner.workbench.daily_attendance.serializer

import com.steiner.workbench.daily_attendance.model.Goal
import kotlinx.serialization.KSerializer

object GoalSerializer: SealedClassSerialzer<Goal>() {
    override val serializer: KSerializer<Goal> = Goal.serializer()
}