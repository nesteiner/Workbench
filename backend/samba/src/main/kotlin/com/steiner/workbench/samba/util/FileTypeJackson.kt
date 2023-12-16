package com.steiner.workbench.samba.util

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.databind.DeserializationContext
import com.fasterxml.jackson.databind.JsonDeserializer
import com.fasterxml.jackson.databind.JsonSerializer
import com.fasterxml.jackson.databind.SerializerProvider
import com.steiner.workbench.samba.model.FileType
import org.springframework.boot.jackson.JsonComponent

@JsonComponent
class FileTypeJackson {
    class Serializer: JsonSerializer<FileType>() {
        override fun serialize(value: FileType, gen: JsonGenerator, serializers: SerializerProvider) {
            gen.writeString(value.toString())
        }
    }

    class Deserializer: JsonDeserializer<FileType>() {
        override fun deserialize(p: JsonParser, ctxt: DeserializationContext): FileType {
            val text = p.text
            return FileType.from(text)
        }
    }
}