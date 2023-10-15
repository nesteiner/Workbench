package com.steiner.workbench.todolist.util

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
import org.springframework.boot.jackson.JsonComponent
import java.text.ParseException
import java.text.SimpleDateFormat


@JsonComponent
class CustomJackson {
    class Serializer: JsonSerializer<Instant>() {
        override fun serialize(value: Instant, gen: JsonGenerator, serializers: SerializerProvider) {
            val isostring = value.toString()
            val date = try {
                formatDateFormat.parse(isostring)
            } catch (exception: ParseException) {
                truncedDateFormat.parse(isostring)
            }

            val result = parseDateFormat.format(date)
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