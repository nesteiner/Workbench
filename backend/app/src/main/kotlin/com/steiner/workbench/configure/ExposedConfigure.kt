package com.steiner.workbench.configure

import org.jetbrains.exposed.spring.autoconfigure.ExposedAutoConfiguration
import org.jetbrains.exposed.sql.DatabaseConfig
import org.jetbrains.exposed.sql.ExperimentalKeywordApi
import org.springframework.boot.autoconfigure.ImportAutoConfiguration
import org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
@ImportAutoConfiguration(
    value = [ExposedAutoConfiguration::class],
    exclude = [DataSourceTransactionManagerAutoConfiguration::class]
)
class ExposedConfigure {
    @Bean
    fun databaseConfig() = DatabaseConfig {
        @OptIn(ExperimentalKeywordApi::class)
        preserveKeywordCasing = true
    }
}