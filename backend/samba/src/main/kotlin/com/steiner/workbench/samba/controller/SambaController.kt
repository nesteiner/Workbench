package com.steiner.workbench.samba.controller

import com.steiner.workbench.common.util.Response
import com.steiner.workbench.samba.model.SambaFile
import com.steiner.workbench.samba.request.LoginRequest
import com.steiner.workbench.samba.util.SambaUtil
import com.steiner.workbench.websocket.endpoint.WebSocketEndpoint
import com.steiner.workbench.websocket.model.Operation
import jakarta.servlet.http.HttpServletResponse
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RequestPart
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.multipart.MultipartFile

@RestController
@RequestMapping("/{uid}/samba")
class SambaController {
    @Autowired
    lateinit var sambaUtil: SambaUtil

    @PostMapping
    fun login(@RequestBody request: LoginRequest): Response<Unit> {
        sambaUtil.loginReplace(request.url, request.username, request.password)
        return Response.Ok("login ok", Unit)
    }

    @GetMapping(params = ["path"])
    fun findFiles(@RequestParam("path") path: String, @RequestParam("show-hidden", required = false) showHidden: Boolean): Response<List<SambaFile>> {
        return if (path == "/") {
            Response.Ok("list root", sambaUtil.listRoot(showHidden))
        } else {
            Response.Ok("list $path", sambaUtil.listFiles(path, showHidden))
        }
    }

    @DeleteMapping(params = ["path"])
    fun deleteFile(@RequestParam("path") path: String, @PathVariable("uid") uid: String): Response<Unit> {
        val file = sambaUtil.file(path)
        if (file.isDirectory) {
            sambaUtil.deleteDirectory(path)
        } else {
            sambaUtil.deleteFile(path)
        }

        WebSocketEndpoint.notifyFrom(uid, Operation.SambaUpdate(file.parent))

        return Response.Ok("delete ok", Unit)
    }

    @PostMapping(params = ["path"])
    fun createDirectory(@RequestParam("path") path: String, @PathVariable("uid") uid: String): Response<Unit> {
        val sambafile = sambaUtil.file(path)
        if (!sambafile.exists()) {
            sambaUtil.createDirectory(path)
        }

        WebSocketEndpoint.notifyFrom(uid, Operation.SambaUpdate(sambafile.parent))
        return Response.Ok("create dir ok", Unit)
    }

    @PostMapping("/upload", consumes = ["multipart/form-data"])
    fun uploadFile(@RequestPart("file") file: MultipartFile,
                   @RequestPart("path") path: String,
                   @PathVariable("uid") uid: String): Response<Unit> {

        sambaUtil.uploadFile(remotepath = path, filename = file.originalFilename ?: "untitled", inputStream = file.inputStream)

        WebSocketEndpoint.notifyFrom(uid, Operation.SambaUpdate(path))
        return Response.Ok("upload ok", Unit)
    }

    @GetMapping("/download", params = ["path"])
    fun downloadFile(@RequestParam("path") path: String,
                     response: HttpServletResponse) {
        val sambafile = sambaUtil.file(path)

        response.setHeader("Content-Type", "application/octet-stream")
        response.setHeader("Content-Length", "${sambafile.length()}")

        val outputStream = response.outputStream
        sambaUtil.downloadFile(sambafile, outputStream)
    }
}