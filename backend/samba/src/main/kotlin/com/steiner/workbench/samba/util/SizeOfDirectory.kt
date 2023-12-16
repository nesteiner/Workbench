package com.steiner.workbench.samba.util

import jcifs.smb1.smb1.SmbFile

fun sizeOfDirectory(directory: SmbFile): Long {
    if (directory.isFile) {
        throw Exception("is not a Directory")
    }

    return sizeOfDirectory0(directory)
}

private fun sizeOfDirectory0(directory: SmbFile): Long {
    var total = 0L
    directory.listFiles().forEach {
        val size = if (it.isDirectory) {
            sizeOfDirectory0(it)
        } else {
            it.length()
        }

        total += size
    }

    return total
}