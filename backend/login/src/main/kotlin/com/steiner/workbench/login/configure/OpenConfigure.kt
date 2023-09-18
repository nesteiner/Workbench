package com.steiner.workbench.login.configure

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "open")
data class OpenConfigure(
        val urls: Array<String>
)