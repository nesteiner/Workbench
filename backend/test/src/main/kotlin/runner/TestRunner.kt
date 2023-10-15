package runner

import org.jetbrains.exposed.sql.SchemaUtils
import org.jetbrains.exposed.sql.insert
import org.springframework.boot.ApplicationArguments
import org.springframework.boot.ApplicationRunner
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import table.Items

@Component
@Transactional
class TestRunner: ApplicationRunner {
    override fun run(args: ApplicationArguments?) {
        SchemaUtils.create(Items)

        Items.insert {
            it[name] = "hello"
            it[age] = 2
        }
    }
}