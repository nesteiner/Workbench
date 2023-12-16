package com.steiner.workbench.samba.extension

import java.net.URI

fun String.urljoin(other: String): String {
    val url1 = if (this.endsWith("/")) {
        URI(this)
    } else {
        URI("$this/")
    }

    val url2 = URI(other)
    val url3 = url1.resolve(url2)
    return url3.toString()
}