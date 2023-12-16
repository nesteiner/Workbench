package com.steiner.workbench.samba.controller

import com.steiner.workbench.common.util.Response
import com.steiner.workbench.samba.model.SambaFile
import com.steiner.workbench.samba.request.LoginRequest
import com.steiner.workbench.samba.util.SambaUtil
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import jcifs.smb1.smb1.SmbAuthException
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RequestPart
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.multipart.MultipartFile
import java.io.BufferedInputStream
import java.io.File
import java.io.RandomAccessFile
import java.net.URLConnection

@RestController
@RequestMapping("/samba")
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
    fun deleteFile(@RequestParam("path") path: String): Response<Unit> {
        val file = sambaUtil.file(path)
        if (file.isDirectory) {
            sambaUtil.deleteDirectory(path)
        } else {
            sambaUtil.deleteFile(path)
        }

        return Response.Ok("delete ok", Unit)
    }

    @PostMapping(params = ["path"])
    fun createDirectory(@RequestParam("path") path: String): Response<Unit> {
        val sambafile = sambaUtil.file(path)
        if (!sambafile.exists()) {
            sambaUtil.createDirectory(path)
        }

        return Response.Ok("create dir ok", Unit)
    }


    @GetMapping("/size", params = ["path"])
    fun findSize(@RequestParam("path") path: String): Response<Long> {
        return Response.Ok("size of $path", sambaUtil.sizeof(path))
    }

    @PostMapping("/upload", consumes = ["multipart/form-data"])
    fun uploadFile(@RequestPart("file") file: MultipartFile,
                   @RequestPart("path") path: String): Response<Unit> {

        sambaUtil.uploadFile(remotepath = path, filename = file.originalFilename ?: "untitled", inputStream = file.inputStream)

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

    @PostMapping("/check/login")
    fun checkLogin(@RequestBody request: LoginRequest): Response<Boolean> {
        try {
            sambaUtil.login(request.url, request.username, request.password)
            return Response.Ok("check ok", true)
        } catch (exception: SmbAuthException) {
            return Response.Ok("check failed", false)
        }

    }
}