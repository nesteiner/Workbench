package com.steiner.workbench.daily_attendance.serializer

import com.steiner.workbench.daily_attendance.model.Icon
import kotlinx.serialization.KSerializer
object IconSerializer: SealedClassSerialzer<Icon>() {
    override val serializer: KSerializer<Icon> = Icon.serializer()
}