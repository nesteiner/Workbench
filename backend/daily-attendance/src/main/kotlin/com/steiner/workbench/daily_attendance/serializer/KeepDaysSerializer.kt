package com.steiner.workbench.daily_attendance.serializer

import com.steiner.workbench.daily_attendance.model.KeepDays
import kotlinx.serialization.KSerializer

object KeepDaysSerializer: SealedClassSerialzer<KeepDays>() {
    override val serializer: KSerializer<KeepDays> = KeepDays.serializer()
}