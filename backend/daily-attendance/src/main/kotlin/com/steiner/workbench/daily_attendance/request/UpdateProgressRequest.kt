package com.steiner.workbench.daily_attendance.request

import com.steiner.workbench.daily_attendance.model.Progress
import com.steiner.workbench.daily_attendance.serializer.ProgressSerializer
import kotlinx.serialization.Serializable

class UpdateProgressRequest(
        val id: Int,
        @Serializable(with = ProgressSerializer::class)
        val progress: Progress
)