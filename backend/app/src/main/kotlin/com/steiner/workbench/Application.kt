package com.steiner.workbench

import org.jetbrains.exposed.spring.autoconfigure.ExposedAutoConfiguration
import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.ImportAutoConfiguration
import org.springframework.boot.autoconfigure.SpringBootApplication
import java.time.ZoneId
import java.util.TimeZone

@SpringBootApplication
@ImportAutoConfiguration(ExposedAutoConfiguration::class)
class Application

fun main(args: Array<String>) {
    TimeZone.setDefault(TimeZone.getTimeZone(ZoneId.of("Asia/Shanghai")))
    SpringApplication.run(Application::class.java, *args)
}