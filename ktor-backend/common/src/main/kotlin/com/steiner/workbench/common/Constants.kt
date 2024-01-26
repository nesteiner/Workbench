package com.steiner.workbench.common


/// for common image items
const val `image-item-name-length` = 256
const val `image-item-path-length` = 256

/// for login
const val `normal-jwt` = "normal-jwt"
const val `admin-jwt` = "admin-jwt"
const val `role-admin` = "admin"
const val `role-default` = "user"

const val `role-name-length` = 16

const val `user-name-length` = 24
const val `user-email-length` = 48
const val `user-password-hash-length` = 256

/// for todolist
const val `task-project-name-length` = 32
const val `task-group-name-length` = 32
const val `tag-name-length` = 32
const val `task-name-length` = 64
const val `subtask-name-length` = 32
const val `tag-color-length` = 16
const val `priority-name-length` = 16

/// for validate
const val `user-request-username-length-max` = `user-name-length`
const val `user-request-password-length-max` = 16
const val `user-request-email-length-max` = `user-email-length`
const val `common-string-length-min` = 5

val emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\$".toRegex()
val hexColorRegex = "^#(?:[0-9a-fA-F]{3}){1,2}\$\n".toRegex()