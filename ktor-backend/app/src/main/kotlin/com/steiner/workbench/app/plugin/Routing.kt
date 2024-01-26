package com.steiner.workbench.app.plugin

import com.steiner.workbench.common.service.ImageItemService
import com.steiner.workbench.common.util.urljoin
import com.steiner.workbench.login.routingLogin
import com.steiner.workbench.todolist.routingTodolist
import io.ktor.http.*
import io.ktor.http.content.*
import io.ktor.server.application.*
import io.ktor.server.plugins.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.koin.ktor.ext.inject
import java.io.BufferedOutputStream
import java.io.File
import java.util.*

fun Application.configureRouting() {
    val imageItemService: ImageItemService by inject<ImageItemService>()
    val imageFolderPath = environment.config.property("app.storage.image-url").getString()
    /// routing of image items
    routing {
        route("image") {
            post("/upload") {
                val data = call.receiveMultipart()
                data.forEachPart { part ->
                    if (part is PartData.FileItem) {
                        part.streamProvider().use { input ->
                            val filename = "${UUID.randomUUID().toString().slice(1..16)}_${part.originalFileName ?: "untitled"}"
                            val filepath = imageFolderPath.urljoin(filename)
                            val imageitem = imageItemService.insertOne(filename, filepath)

                            File(filepath).apply {
                                if (!exists()) {
                                    createNewFile()
                                }

                                input.transferTo(BufferedOutputStream(this.outputStream()))
                            }
                        }

                        return@forEachPart
                    }
                }
            }

            get("/download/{id}") {
                val id = call.parameters["id"]?.toIntOrNull()
                if (id == null) {
                    throw BadRequestException("no such image item with id $id")
                }

                val imageitem = imageItemService.findOne(id)
                if (imageitem != null) {
                    val file = File(imageitem.path!!)
                    if (file.exists()) {
                        call.respondFile(file)
                    } else {
                        call.respond(HttpStatusCode.NotFound)
                    }
                } else {
                    call.respond(HttpStatusCode.NotFound)
                }
            }

        }
    }

    routingLogin()
    routingTodolist()
}