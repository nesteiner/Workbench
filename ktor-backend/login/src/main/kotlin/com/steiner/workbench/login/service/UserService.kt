package com.steiner.workbench.login.service

import com.steiner.workbench.common.util.dbQuery
import com.steiner.workbench.login.exception.AuthenticationException
import com.steiner.workbench.login.model.User
import com.steiner.workbench.login.request.LoginRequest
import com.steiner.workbench.login.request.PostAdminRequest
import com.steiner.workbench.login.request.PostUserRequest
import com.steiner.workbench.login.request.UpdateUserRequest
import com.steiner.workbench.login.table.UserRole
import com.steiner.workbench.login.table.Users
import io.ktor.server.plugins.*
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction

class UserService(val database: Database, val roleService: RoleService) {
    init {
        transaction(database) {
            SchemaUtils.create(Users)
        }
    }

    suspend fun login(requset: LoginRequest): User = dbQuery(database) {
        val ifuser = findOne(requset.username)
        if (ifuser == null) {
            throw AuthenticationException("no such user")
        }

        if (!ifuser.enabled) {
            throw AuthenticationException("user not enabled")
        }

        if (ifuser.passwordHash != requset.passwordHash) {
            throw AuthenticationException("password error")
        }

        ifuser
    }

    suspend fun insertOne(request: PostUserRequest): User = dbQuery(database) {
        val ifexist = with (Users) {
            selectAll().where(name eq request.username).firstOrNull() != null
        }

        if (ifexist) {
            throw BadRequestException("username duplicate")
        }

        val id = Users.insert {
            it[name] = request.username
            it[email] = request.email
            it[enabled] = request.enabled
            it[passwordHash] = request.passwordHash
        } get Users.id

        val defaultRole = roleService.findDefault()

        UserRole.insert {
            it[userid] = id.value
            it[roleid] = defaultRole.id
        }

        findOne(id.value)!!
    }

    suspend fun insertAdmin(request: PostAdminRequest): User = dbQuery(database) {
        val ifexist = with (Users) {
            selectAll().where(name eq request.username).firstOrNull() != null
        }

        if (ifexist) {
            throw BadRequestException("username duplicate")
        }

        val id = Users.insert {
            it[name] = request.username
            it[email] = request.email
            it[enabled] = request.enabled
            it[passwordHash] = request.passwordHash
        } get Users.id

        val adminRole = roleService.findAdmin()
        UserRole.insert {
            it[userid] = id.value
            it[roleid] = adminRole.id
        }

        findOne(id.value)!!
    }

    suspend fun updateOne(request: UpdateUserRequest): User = dbQuery(database) {
        val ifexist = with (Users) {
            selectAll().where(id eq request.id).firstOrNull() != null
        }

        if (!ifexist) {
            throw BadRequestException("no such user")
        }

        with (Users) {
            update({ id eq request.id }) {
                if (request.username != null) {
                    it[name] = request.username
                }

                if (request.email != null) {
                    it[email] = request.email
                }

                if (request.enabled != null) {
                    it[enabled] = request.enabled
                }

                if (request.passwordHash != null) {
                    it[passwordHash] = request.passwordHash
                }
            }
        }

        findOne(request.id)!!
    }

    suspend fun findOne(id: Int): User? = dbQuery(database) {
        with (Users) {
            selectAll().where(this.id eq id).firstOrNull()?.let {
                User(
                    id = it[this.id].value,
                    name = it[name],
                    roles = roleService.rolesOf(id),
                    email = it[email],
                    enabled = it[enabled],
                    passwordHash = it[passwordHash]
                )
            }
        }
    }

    suspend fun findOne(name: String): User? = dbQuery(database) {
        with (Users) {
            selectAll().where(this.name eq name).firstOrNull()?.let {
                val id = it[this.id].value

                User(
                    id = id,
                    name = it[this.name],
                    roles = roleService.rolesOf(id),
                    email = it[email],
                    enabled = it[enabled],
                    passwordHash = it[passwordHash]
                )
            }
        }
    }

    suspend fun clear() {
        dbQuery(database) {
            Users.deleteAll()
        }
    }
}