package com.steiner.workbench.common.util

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.databind.DeserializationContext
import com.fasterxml.jackson.databind.JsonDeserializer
import com.fasterxml.jackson.databind.JsonSerializer
import com.fasterxml.jackson.databind.SerializerProvider

import com.steiner.workbench.common.formatDateFormat
import com.steiner.workbench.common.parseDateFormat
import com.steiner.workbench.common.truncedDateFormat
import kotlinx.datetime.Instant
import kotlinx.datetime.UtcOffset
import kotlinx.datetime.toInstant
import kotlinx.datetime.toLocalDateTime
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.boot.jackson.JsonComponent
import java.time.LocalDateTime


@JsonComponent
class InstantJackson {
    companion object {
        val logger: Logger = LoggerFactory.getLogger(InstantJackson::class.java)
    }

    class Serializer : JsonSerializer<Instant>() {
        override fun serialize(value: Instant, gen: JsonGenerator, serializers: SerializerProvider) {
            val isostring = value.toLocalDateTime(CURRENT_TIME_ZONE).toInstant(UtcOffset(-8)).toString()
            /**
            val date: Date = try {
                formatDateFormat.parse(isostring)
            } catch (exception: ParseException) {
                truncedDateFormat.parse(isostring)
            } catch (exception: NumberFormatException) {
                logger.error("parse error for: ${exception.message ?: "fuck"}")
                logger.error("the iso string is $isostring")
                formatDateFormat.parse(shanghaiNow().toString())
            }

            val result = parseDateFormat.format(date)
            gen.writeString(result)
            **/

            val result: String = try {
                val time = LocalDateTime.parse(isostring, formatDateFormat)
                time.format(formatDateFormat)
            } catch (exception: Exception) {
                val time = LocalDateTime.parse(isostring, truncedDateFormat)
                time.format(truncedDateFormat)
            }

            gen.writeString(result)

        }
    }

    class Deserializer: JsonDeserializer<Instant>() {
        override fun deserialize(p: JsonParser, ctxt: DeserializationContext): Instant {
            val text = p.text
            val date = parseDateFormat.parse(text)
            val isostring = formatDateFormat.format(date)
            return Instant.parse(isostring)
        }
    }
}