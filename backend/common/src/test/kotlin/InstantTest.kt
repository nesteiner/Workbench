import com.steiner.workbench.common.formatDateFormat
import com.steiner.workbench.common.util.now
import org.junit.jupiter.api.Test
import java.time.ZoneOffset
import java.time.ZonedDateTime

class InstantTest {
    @Test
    fun `test serialize instant`() {
//        val instant = shanghaiNow()
//        val isostring = instant.toString()
        val isostring = "2023-12-15T07:07:21.069708Z"
        // val isostring = "2023-12-14T15:58:04.267158Z"

        val date = ZonedDateTime.parse(isostring).toInstant()
        val result = formatDateFormat.format(date.atZone(ZoneOffset.ofHours(8)))
        println(result)

        val now = now()
        println(now)
    }
}