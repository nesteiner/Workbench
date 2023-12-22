package com.steiner.workbench.websocket.model

import kotlinx.serialization.Serializable

@Serializable
class TransferData(
    val fromuid: String,
    val touid: String,
    val message: TransferMessage
)