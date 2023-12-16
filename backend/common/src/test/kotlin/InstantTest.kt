import com.steiner.workbench.common.formatDateFormat
import com.steiner.workbench.common.util.shanghaiNow
import org.junit.jupiter.api.Test

class InstantTest {
    @Test
    fun `test serialize instant`() {
//        val instant = shanghaiNow()
//        val isostring = instant.toString()
        val isostring = "2023-12-15T07:07:21.069708Z"
        // val isostring = "2023-12-14T15:58:04.267158Z"

        repeat(1000) {
            formatDateFormat.parse(isostring)
        }
    }
}