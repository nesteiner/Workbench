package com.steiner.workbench.common

import java.text.SimpleDateFormat

const val ROLE_ADMIN = "admin"
const val AUTHORIZATIOIN = "Authorization"
const val USERNAME_ATTRIBUTE = "username"
const val JWTTOKEN_ATTRIBUTE = "jwttoken"

const val SUBTASK_NAME_LENGTH = 128
const val TASK_NAME_LENGTH = 128
const val TASK_GROUP_NAME_LENGTH = 128
const val TASK_PROJECT_NAME_LENGTH = 32
const val TAG_NAME_LENGTH = 32
const val AVATAR_URL_LENGTH = 128
const val IMAGE_ITEM_NAME_LENGTH = 128
const val IMAGE_ITEM_PATH_LENGTH = 128

const val DEFAULT_AVATAR_ID = 1

const val ISO8601_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
const val TRUNCED_ISO8601_FORMAT = "yyyy-MM-dd'T'HH:mm:ss'Z'"
const val SIMPLE_DATETIME_FORMAT = "yyyy-MM-dd HH:mm"

// for parse yyyy-MM-dd HH:mm string to Date
val parseDateFormat = SimpleDateFormat(SIMPLE_DATETIME_FORMAT)

// for format date into iso8601 string
val formatDateFormat = SimpleDateFormat(ISO8601_FORMAT)

// for parse yyyy-MM-dd'T'HH:mm:ss'Z' string to Date
val truncedDateFormat = SimpleDateFormat(TRUNCED_ISO8601_FORMAT)