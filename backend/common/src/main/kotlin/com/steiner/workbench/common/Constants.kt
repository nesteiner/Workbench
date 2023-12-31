package com.steiner.workbench.common

import java.time.format.DateTimeFormatter
import java.util.*

// for login
const val ROLE_ADMIN = "admin"
const val AUTHORIZATIOIN = "Authorization"
const val USERNAME_ATTRIBUTE = "username"
const val JWTTOKEN_ATTRIBUTE = "jwttoken"

const val USER_NAME_LENGTH = 24
const val USER_EMAIL_LENGTH = 48

// for todolist
const val SUBTASK_NAME_LENGTH = 128
const val TASK_NAME_LENGTH = 128
const val TASK_GROUP_NAME_LENGTH = 128
const val TASK_PROJECT_NAME_LENGTH = 32
const val TAG_NAME_LENGTH = 32
const val AVATAR_URL_LENGTH = 128
const val IMAGE_ITEM_NAME_LENGTH = 256
const val IMAGE_ITEM_PATH_LENGTH = 256

const val DEFAULT_AVATAR_ID = 1

const val ISO8601_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
const val TRUNCED_ISO8601_FORMAT = "yyyy-MM-dd'T'HH:mm:ss'Z'"
const val SIMPLE_DATETIME_FORMAT = "yyyy-MM-dd HH:mm"

// for parse yyyy-MM-dd HH:mm string to Date
val parseDateFormat = DateTimeFormatter.ofPattern(SIMPLE_DATETIME_FORMAT, Locale.CHINA)

// for format date into iso8601 string
val formatDateFormat = DateTimeFormatter.ofPattern(ISO8601_FORMAT, Locale.CHINA)

// for parse yyyy-MM-dd'T'HH:mm:ss'Z' string to Date
val truncedDateFormat = DateTimeFormatter.ofPattern(TRUNCED_ISO8601_FORMAT, Locale.CHINA)

// for daily attendance
const val DAILY_ATTENDANCE_NAME_LENGTH = 24
const val DAILY_ATTENDANCE_ENCOURAGEMENT_LENGTH = 24

const val DAILY_ATTENDANCE_IMAGE_NAME_LENGTH = 256
const val DAILY_ATTENDANCE_IMAGE_PATH_LENGTH = 256

const val CLIPBOARD_TEXT_LENGTH = 1024
const val CLIPBOARD_IMAGE_NAME_LENGTH = 128
const val CLIPBOARD_IMAGE_PATH_LENGTH = 128
const val CLIPBOARD_IMAGE_SIZE_LENGTH = 16

const val oneKB = 1024L
const val oneMB = 1024 * 1024L

const val SPACE_CHARACTER = "%20"