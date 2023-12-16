package com.steiner.workbench.controller

import com.steiner.workbench.common.util.Response
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class CheckConnectionController {
    @GetMapping("/check")
    fun check(): Response<Unit> {
        return Response.Ok("ok", Unit)
    }
}