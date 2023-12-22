package com.steiner.workbench.websocket.encoder

import com.steiner.workbench.websocket.model.TransferData
import jakarta.websocket.Encoder
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class TransferDataEncoder: Encoder.Text<TransferData> {
    override fun encode(data: TransferData): String {
        return Json.encodeToString(data)
    }
}