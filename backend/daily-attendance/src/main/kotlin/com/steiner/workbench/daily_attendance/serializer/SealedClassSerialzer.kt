package com.steiner.workbench.daily_attendance.serializer

import kotlinx.serialization.KSerializer
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder

abstract class SealedClassSerialzer<T>: KSerializer<T> {
    abstract val serializer: KSerializer<T>

    override val descriptor: SerialDescriptor get() = this.serializer.descriptor

    override fun serialize(encoder: Encoder, value: T) {
        encoder.encodeSerializableValue(serializer, value)
    }

    override fun deserialize(decoder: Decoder): T {
        return serializer.deserialize(decoder)
    }
}