package com.steiner.workbench.daily_attendance.controller

import com.steiner.workbench.common.util.Response
import com.steiner.workbench.daily_attendance.model.Icon
import com.steiner.workbench.daily_attendance.model.ImageItem
import com.steiner.workbench.daily_attendance.request.PostIconImageRequest
import com.steiner.workbench.daily_attendance.request.PostIconWordRequest
import com.steiner.workbench.daily_attendance.service.IconService
import jakarta.servlet.http.HttpServletResponse
import jakarta.validation.Valid
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.validation.BindingResult
import org.springframework.validation.annotation.Validated
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile
import java.io.BufferedInputStream
import java.io.File
import java.io.FileInputStream
import java.text.SimpleDateFormat
import java.util.*

@RestController
@RequestMapping("/daily-attendance/icon")
@Validated
class IconController(val sdf: SimpleDateFormat = SimpleDateFormat("yyyyMMdd")) {
    companion object {
        const val bufferSize = 1024 * 1024 * 10
    }

    @Autowired
    lateinit var iconService: IconService
    @Value("\${file.storage.daily-attendance-url}")
    lateinit var imagefolderPath: String

    @PostMapping("/upload")
    fun uploadImage(@RequestParam("file") image: MultipartFile): Response.Ok<ImageItem> {
        val filename = image.originalFilename ?: "untitled"
        val filepath = "$imagefolderPath/${UUID.randomUUID()}_${sdf.format(Date())}_${filename.replace(" ", "")}"
        val imageitem = iconService.insertIconImage(filename, filepath)

        image.transferTo(File(filepath))
        return Response.Ok("update ok", imageitem)
    }

    @GetMapping("/download/{id}")
    fun findImage(@PathVariable("id") id: Int, response: HttpServletResponse) {
        val imageitem = iconService.findIconImage(id)
        if (imageitem != null) {
            val file = File(imageitem.path)
            if (file.exists()) {
                response.reset()
                val buffer = ByteArray(bufferSize)
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
}