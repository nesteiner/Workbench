package com.steiner.workbench

import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication

@SpringBootApplication(scanBasePackages = ["com.steiner.workbench", "com.steiner.workbench.login.controller"])
class Application

fun main(args: Array<String>) {
    SpringApplication.run(Application::class.java, *args)
}