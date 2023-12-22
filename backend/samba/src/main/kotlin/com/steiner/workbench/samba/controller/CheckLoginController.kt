package com.steiner.workbench.samba.controller

import com.steiner.workbench.common.util.Response
import com.steiner.workbench.samba.request.LoginRequest
import com.steiner.workbench.samba.util.SambaUtil
import jcifs.smb1.smb1.SmbAuthException
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/samba/check/login")
class CheckLoginController {
    @Autowired
    lateinit var sambaUtil: SambaUtil

    @PostMapping
    fun checkLogin(@RequestBody request: LoginRequest): Response<Boolean> {
        try {
            sambaUtil.login(request.url, request.username, request.password)
            return Response.Ok("check ok", true)
        } catch (exception: SmbAuthException) {
            return Response.Ok("check failed", false)
        }

    }
}