package com.steiner.workbench.daily_attendance.serializer

import com.steiner.workbench.daily_attendance.model.Frequency
import kotlinx.serialization.KSerializer

object FrequencySerializer: SealedClassSerialzer<Frequency>() {
    override val serializer: KSerializer<Frequency> = Frequency.serializer()
}