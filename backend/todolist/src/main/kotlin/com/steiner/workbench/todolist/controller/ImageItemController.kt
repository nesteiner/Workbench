package com.steiner.workbench.todolist.controller

import com.steiner.workbench.common.util.Response
import com.steiner.workbench.todolist.model.ImageItem
import com.steiner.workbench.todolist.service.ImageItemService
import jakarta.servlet.http.HttpServletResponse
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.client.HttpServerErrorException.InternalServerError
import org.springframework.web.multipart.MultipartFile
import java.io.BufferedInputStream
import java.io.File
import java.io.FileInputStream
import java.text.SimpleDateFormat
import java.util.*

@RestController
@RequestMapping("/{uid}/todolist/image")
class ImageItemController(
        val sdf: SimpleDateFormat = SimpleDateFormat("yyyyMMdd")
) {
    @Autowired
    lateinit var imageitemService: ImageItemService
    @Value("\${file.storage.todolist-url}")
    lateinit var imagefolderPath: String

    @PostMapping("/upload")
    fun uploadImage(@RequestParam("file") image: MultipartFile): Response<ImageItem> {
        val filename = "${UUID.randomUUID().toString().slice(1..16)}_${image.originalFilename ?: "untitled"}"
        val filepath = "$imagefolderPath/${UUID.randomUUID().toString().slice(1..16)}_${sdf.format(Date())}_${filename.replace(" ", "")}"
        val imageitem = imageitemService.insertOne(filename, filepath)

        File(filepath).apply {
            if (!exists()) {
                createNewFile()
            }

            image.transferTo(this)
        }

        return Response.Ok("update ok", imageitem)
    }

    @GetMapping("/download/{id}")
    fun findOne(@PathVariable("id") id: Int, response: HttpServletResponse) {
        val imageitem = imageitemService.findOne(id)
        if (imageitem != null) {
            val file = File(imageitem.path)
            if (file.exists()) {
                response.reset()
                val buffer = ByteArray(1024 * 1024 * 10)
                val fis = FileInputStream(file)
                val bis = BufferedInputStream(fis)
                val os = response.outputStream
                response.setContentLengthLong(file.length())

                var result = bis.read(buffer)
                while (result != -1) {
                    os.write(buffer, 0, result)
                    result = bis.read(buffer)
                }

                os.flush()
                fis.close()
                bis.close()
                os.close()
            }
        }
    }

    @GetMapping("/download/default")
    fun findOne(response: HttpServletResponse): Response<ImageItem> {
        val imageitem = imageitemService.findOne("default.png")!!
        return Response.Ok("this image item", imageitem)
    }

}