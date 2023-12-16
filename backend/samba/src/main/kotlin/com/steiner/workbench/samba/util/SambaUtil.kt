package com.steiner.workbench.samba.util

import com.steiner.workbench.samba.extension.urljoin
import com.steiner.workbench.samba.model.FileType
import com.steiner.workbench.samba.model.SambaFile
import jcifs.smb1.UniAddress
import jcifs.smb1.smb1.NtlmPasswordAuthentication
import jcifs.smb1.smb1.SmbAuthException
import jcifs.smb1.smb1.SmbFile
import jcifs.smb1.smb1.SmbRandomAccessFile
import jcifs.smb1.smb1.SmbSession
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import java.io.BufferedInputStream
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.lang.RuntimeException
import java.util.Date


/// when using this component,
/// you must login at first, or using loginReplace
@Component
class SambaUtil {
    companion object {
        val logger: Logger = LoggerFactory.getLogger(SambaUtil::class.java)
        const val bufferSize = 1024 * 1024 * 10
    }

    private var _auth: NtlmPasswordAuthentication? = null
    val auth: NtlmPasswordAuthentication
        get() {
            return _auth ?: throw RuntimeException("_auth is null, which mean user haven't login yet")
        }

    var url: String = ""
    fun login(url: String, username: String, password: String): NtlmPasswordAuthentication {
        if (_auth == null) {
            val uniaddress = UniAddress.getByName(url)

            val auth1 = NtlmPasswordAuthentication(url, username, password)
            SmbSession.logon(uniaddress, auth1)
            this.url = url

            _auth = auth1

        }

        return _auth!!
    }

    fun loginReplace(url: String, username: String, password: String): NtlmPasswordAuthentication {
        _auth = null
        return login(url, username, password)
    }

    fun file(path: String): SmbFile {
        return SmbFile(path, auth)
    }

    fun randomAccessFile(path: String, mode: String = "r"): SmbRandomAccessFile {
        val sambafile = file(path)
        return SmbRandomAccessFile(sambafile, mode)
    }

    /// reading data from inputStream, and then write the data to SmbFile(remotepath.join(filename))
    fun uploadFile(remotepath: String, filename: String, inputStream: InputStream)  {
        var bufferInputStream: BufferedInputStream? = null
        var outputStream: OutputStream? = null

        try {
            val path = remotepath.urljoin(filename)
            val sambafile = file(path)
            val sambafolder = file(remotepath)

            if (!sambafolder.exists()) {
                sambafolder.mkdirs()
            }

            bufferInputStream = BufferedInputStream(inputStream)
            outputStream = sambafile.outputStream

            val bytes = ByteArray(bufferSize)
            var n = bufferInputStream.read(bytes)

            while (n != -1) {
                outputStream.write(bytes, 0, n)
                n = bufferInputStream.read(bytes)
            }

            outputStream.flush()
        } catch (exception: Exception) {
            logger.error(exception.message, exception)
        } finally {
             try {
                 bufferInputStream?.close()
                 outputStream?.close()
             } catch (exception: IOException) {
                 logger.error(exception.message, exception)
             }
        }
    }

    /// reading data from (remotepath, filename), and then write the data into outputStream
    /// ATTENTION this api need test
    fun downloadFile(sambafile: SmbFile, outputStream: OutputStream)  {
        var bufferedInputStream: BufferedInputStream? = null

        try {
            if (sambafile.exists()) {
                bufferedInputStream = BufferedInputStream(sambafile.inputStream)
                val bytes = ByteArray(bufferSize)
                var n = bufferedInputStream.read(bytes)

                while (n != -1) {
                    outputStream.write(bytes, 0, n)
                    n = bufferedInputStream.read(bytes)
                }

                outputStream.flush()
            }
        } catch (exception: Exception) {
            logger.error(exception.message, exception)
        } finally {
            try {
                bufferedInputStream?.close()
                outputStream.close()
            } catch (exception: IOException) {
                logger.error(exception.message, exception)
            }
        }
    }

    fun deleteFile(remotepath: String) {
        val file = file(remotepath)

        if (file.isFile) {
            file.delete()
        }
    }

    fun deleteFile(file: SmbFile) {
        if (file.isFile) {
            file.delete()
        }
    }

    fun deleteDirectory(remotepath: String) {
        val remotepath1 = if (remotepath.endsWith("/")) {
            remotepath
        } else {
            "$remotepath/"
        }

        val sambafile = file(remotepath1)

        if (sambafile.isDirectory) {
            deleteDirectory(sambafile)
        }
    }

    fun deleteDirectory(file: SmbFile) {
        if (file.isFile) {
            return
        }

        file.listFiles().forEach {
            if (it.isFile) {
                deleteFile(it)
            } else if (it.isDirectory) {
                deleteDirectory(it)
            }
        }

        file.delete()
    }

    fun listRoot(showHidden: Boolean): List<SambaFile> {
        val sambafile = file("smb://$url")

        val files = if (showHidden) {
            sambafile.listFiles()
        } else {
            sambafile.listFiles { file ->
                !file.name.startsWith(".")
            }
        }

        return files
            .map {
                val size = if (it.isDirectory) {
                    null
                } else {
                    sizeof(it.path)
                }

                SambaFile(
                    name = it.name,
                    path = it.path,
                    lastModified = Date(it.lastModified()),
                    attributes = it.attributes,
                    size = size,
                    filetype = FileType.from(it)
                )
            }

    }

    fun listFiles(remotepath: String, showHidden: Boolean): List<SambaFile> {
        val remoetpath1 = if (remotepath.endsWith("/")) {
            remotepath
        } else {
            "$remotepath/"
        }

        val sambafile = file(remoetpath1)
        val files = if (showHidden) {
            sambafile.listFiles()
        } else {
            sambafile.listFiles { file ->
                !file.name.startsWith(".")
            }
        }

        return files
            .map {
                val filetype = FileType.from(it)
                val size = when (filetype) {
                    FileType.directory -> null
                    else -> it.length()
                }

                SambaFile(
                    name = it.name,
                    path = it.path,
                    lastModified = Date(it.lastModified()),
                    attributes = it.attributes,
                    size = size,
                    filetype = filetype
                )
            }
    }

    fun createDirectory(remotepath: String) {
        val dirname = if (remotepath.endsWith("/")) {
            remotepath
        } else {
            "$remotepath/"
        }

        val sambadir = file(dirname)
        sambadir.mkdirs()
    }

    fun sizeof(remotepath: String): Long {
        val sambafile = file(remotepath)
        return if (sambafile.isFile) {
            sambafile.length()
        } else {
            sizeOfDirectory(sambafile)
        }
    }
}