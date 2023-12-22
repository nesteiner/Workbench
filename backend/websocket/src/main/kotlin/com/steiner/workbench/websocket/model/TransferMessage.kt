package com.steiner.workbench.websocket.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class TransferMessage {
    @Serializable
    @SerialName("Notification")
    class Notification(val operation: Operation): TransferMessage()

    @Serializable
    @SerialName("Error")
    class Error(val message: String): TransferMessage()
}