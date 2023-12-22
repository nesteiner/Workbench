package com.steiner.workbench.websocket.decoder

import com.steiner.workbench.websocket.model.TransferData
import jakarta.websocket.Decoder
import kotlinx.serialization.json.Json

class TransferDataDecoder: Decoder.Text<TransferData> {
    override fun decode(s: String): TransferData {
        return Json.decodeFromString(s)
    }

    override fun willDecode(s: String): Boolean {
        return true
    }
}