import com.steiner.workbench.common.ISO8601_FORMAT
import com.steiner.workbench.common.SIMPLE_DATETIME_FORMAT
import com.steiner.workbench.common.formatDateFormat
import com.steiner.workbench.todolist.table.ImageItems
import com.steiner.workbench.common.util.shanghaiNow
import kotlinx.datetime.*
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.StdOutSqlLogger
import org.jetbrains.exposed.sql.addLogger
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.transactions.transaction
import org.junit.jupiter.api.Test
import java.text.SimpleDateFormat
import java.util.Date

class BackendTest {
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

    @Test
    fun testDateFormat() {
        /**val format = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        val sdf = SimpleDateFormat(format)
        sdf.isLenient = false
        val string = "2023-09-21T09:17:31.267087Z"
        println(sdf.parse(string))
        **/
        val date = Date.from(java.time.Instant.now())
        val format = "yyyy-MM-dd HH:mm"
        val sdf = SimpleDateFormat(format)

        println(sdf.format(date))
        /**
         *        val datetime = parseDateFormat.parse(datetimeString)
         *         val isostring = formatDateFormat.format(datetime)
         *         return Instant.parse(isostring)
         */


        val parseDateFormat = SimpleDateFormat(SIMPLE_DATETIME_FORMAT)
        val formatDateFormat = SimpleDateFormat(ISO8601_FORMAT)

        val string = "2023-09-21 09:17"
        val datetime = parseDateFormat.parse(string)
        val isostring = formatDateFormat.format(datetime)
        val result = Instant.parse(isostring).toString()
        println(formatDateFormat.parse(result))
    }

    @Test
    fun testNow() {
        val timezone = TimeZone.currentSystemDefault()
        println(timezone)
        println(shanghaiNow())
        println(Clock.System.now().toLocalDateTime(timezone))
    }

    @Test
    fun `test datetime format`() {
        val s = "2023-12-10T11:52:36.846660Z"
        formatDateFormat.parse(s)
    }
}