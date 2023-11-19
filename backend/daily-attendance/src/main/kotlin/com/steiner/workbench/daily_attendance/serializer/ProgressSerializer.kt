package com.steiner.workbench.daily_attendance.serializer

import com.steiner.workbench.daily_attendance.model.Progress
import kotlinx.serialization.KSerializer

object ProgressSerializer: SealedClassSerialzer<Progress>() {
    override val serializer: KSerializer<Progress> = Progress.serializer()
}