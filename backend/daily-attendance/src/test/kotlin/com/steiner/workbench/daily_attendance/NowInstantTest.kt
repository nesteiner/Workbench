package com.steiner.workbench.daily_attendance

import com.steiner.workbench.common.util.CURRENT_TIME_ZONE
import com.steiner.workbench.common.util.now
import org.junit.jupiter.api.Test

class NowInstantTest {
    @Test
    fun `test now instant`() {
        val nowInstant = now()
        println(nowInstant)
        println(CURRENT_TIME_ZONE)
    }
}