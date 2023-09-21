package com.steiner.workbench

import org.jetbrains.exposed.spring.autoconfigure.ExposedAutoConfiguration
import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.ImportAutoConfiguration
import org.springframework.boot.autoconfigure.SpringBootApplication

@SpringBootApplication
@ImportAutoConfiguration(ExposedAutoConfiguration::class)
class Application

fun main(args: Array<String>) {
    SpringApplication.run(Application::class.java, *args)
}