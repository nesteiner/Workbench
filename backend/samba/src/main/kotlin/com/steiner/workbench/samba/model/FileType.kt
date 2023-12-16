package com.steiner.workbench.samba.model

import jcifs.smb1.smb1.SmbFile
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import java.io.BufferedInputStream
import java.net.URLConnection

sealed class FileType {
    companion object {
        val logger: Logger = LoggerFactory.getLogger(FileType::class.java)
        @JvmStatic
        fun from(file: SmbFile): FileType {
            return if (file.isDirectory) {
                directory
            } else if (file.isFile) {
                val type = URLConnection.guessContentTypeFromName(file.name)
                when {
                    type == null -> unknown
                    type.startsWith("text") -> text
                    type.startsWith("image") -> image
                    type.startsWith("video") -> video
                    type.startsWith("audio") -> audio
                    else -> unknown
                }
            } else {
                unknown
            }
        }

        @JvmStatic
        fun from(s: String): FileType {
            return when (s) {
                "text" -> text
                "image" -> image
                "video" -> video
                "audio" -> audio
                "directory" -> directory
                else -> unknown
            }
        }
    }

    object text: FileType()
    object image: FileType()
    object video: FileType()
    object audio: FileType()
    object directory: FileType()
    object unknown: FileType()

    override fun toString(): String {
        return when (this) {
            text -> "text"
            image -> "image"
            video -> "video"
            audio -> "audio"
            directory -> "directory"
            unknown -> "unknown"
        }
    }
}