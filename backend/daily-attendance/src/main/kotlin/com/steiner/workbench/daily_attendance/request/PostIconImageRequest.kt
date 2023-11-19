package com.steiner.workbench.daily_attendance.request

import com.steiner.workbench.daily_attendance.validator.HexColorValid

class PostIconImageRequest(
        val entryId: Int,
        val backgroundId: Int,
        // hex color
        @HexColorValid
        val backgroundColor: String
)