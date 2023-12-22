package com.steiner.workbench.websocket.endpoint

import com.steiner.workbench.websocket.decoder.TransferDataDecoder
import com.steiner.workbench.websocket.encoder.TransferDataEncoder
import com.steiner.workbench.websocket.model.Operation
import com.steiner.workbench.websocket.model.TransferData
import com.steiner.workbench.websocket.model.TransferMessage
import jakarta.websocket.OnClose
import jakarta.websocket.OnError
import jakarta.websocket.OnMessage
import jakarta.websocket.OnOpen
import jakarta.websocket.Session
import jakarta.websocket.server.PathParam
import jakarta.websocket.server.ServerEndpoint
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import java.io.IOException

@Component
@ServerEndpoint("/websocket/{uid}", decoders = [TransferDataDecoder::class], encoders = [TransferDataEncoder::class])
class WebSocketEndpoint {
    companion object {
        val endpointMap = mutableMapOf<String, WebSocketEndpoint>()
        val logger = LoggerFactory.getLogger(WebSocketEndpoint::class.java)
        const val SERVER_NAME = "server"

        @JvmStatic
        fun notifyAll(fromuid: String, operation: Operation) {
            endpointMap.values.filter {
                it.uid != fromuid
            }.forEach {
                val data = TransferData(
                    fromuid = SERVER_NAME,
                    touid = it.uid,
                    message = TransferMessage.Notification(operation)
                )
                it.session.asyncRemote.sendObject(data)
            }
        }
    }

    lateinit var uid: String
    lateinit var session: Session

    @OnOpen
    fun onOpen(@PathParam("uid") uid: String, session: Session) {
        logger.info("get connection which uid is $uid")

        if (endpointMap.containsKey(uid) || uid == SERVER_NAME) {
            val data = TransferData(
                fromuid = SERVER_NAME,
                touid = uid,
                message = TransferMessage.Error("uid conflict")
            )

            session.basicRemote.sendObject(data)
        } else {
            this.uid = uid
            this.session = session
            endpointMap.put(uid, this)
        }
    }

    @OnMessage
    fun onMessage(message: TransferData, session: Session) {
        val touid = message.touid
        val endpoint = endpointMap.get(touid)
        if (endpoint != null) {
            endpoint.session.basicRemote.sendObject(message)
        } else {
            val response = TransferData(
                fromuid = SERVER_NAME,
                touid = message.fromuid,
                message = TransferMessage.Error("target is not online")
            )

            session.basicRemote.sendObject(response)
        }
    }

    @OnError
    fun onError(session: Session, throwable: Throwable, @PathParam("uid") uid: String) {
        val data = TransferData(
            fromuid = SERVER_NAME,
            touid = uid,
            message = TransferMessage.Error(throwable.message ?: "Fuck")
        )

        try {
            session.basicRemote.sendObject(data)
        } catch (exception: IOException) {
            logger.error("error in send back ${exception.message ?: "Fuck"}")
        }

        logger.error(throwable.message ?: "Fuck")
    }

    @OnClose
    fun onClose(@PathParam("uid") uid: String) {
        endpointMap.remove(uid)
        logger.info("connection of $uid closed")
    }


}