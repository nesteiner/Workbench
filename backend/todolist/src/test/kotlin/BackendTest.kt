import com.steiner.workbench.todolist.table.ImageItems
import kotlinx.datetime.*
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.StdOutSqlLogger
import org.jetbrains.exposed.sql.addLogger
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.transactions.transaction
import org.junit.jupiter.api.Test
import java.text.SimpleDateFormat

class BackendTest {
    @Test
    fun testInstantAndTimestamp() {
        val isostring = "2023-09-20T08:30:40.143Z"
        val instant = Instant.parse(isostring)
        println(instant.toString())
    }

    @Test
    fun testValid() {
        val format = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        val isostring = "2023-09-20T08:30:40.143Z"
        val sdf = SimpleDateFormat(format)
        println(sdf.parse(isostring))
    }

    @Test
    fun injectFakeImageItem() {
        Database.connect("jdbc:postgresql://localhost/workbench", user = "steiner", password = "779151714", driver = "org.postgresql.Driver")

        transaction {
            addLogger(StdOutSqlLogger)
            ImageItems.insert {
                it[id] = 1
                it[name] = "default.png"
                it[path] = "/home/steiner/workspace/workbench/storage/default.png"
            }
        }

    }
}