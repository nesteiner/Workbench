package com.steiner.workbench.common.util

import java.net.URI

fun String.urljoin(path: String): String {
    val uri = URI(this)
    return uri.resolve(path).toString()
}