package com.steiner.workbench.daily_attendance

import org.junit.jupiter.api.Test
import org.springframework.util.ResourceUtils

class ResourcePathTest {
    @Test
    fun testResoursePath() {
        val file = ResourceUtils.getFile("classpath:assets/不发脾气.png")
        println(file.exists())
    }
}