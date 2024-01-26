package com.steiner.workbench.login.service

import com.steiner.workbench.common.util.dbQuery
import com.steiner.workbench.login.model.Role
import com.steiner.workbench.login.request.PostRoleRequest
import com.steiner.workbench.login.table.Roles
import com.steiner.workbench.login.table.UserRole
import com.steiner.workbench.common.`role-admin`
import com.steiner.workbench.common.`role-default`
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.jetbrains.exposed.sql.transactions.transaction

class RoleService(val database: Database) {
    init {
        transaction(database) {
            SchemaUtils.create(Roles)
            SchemaUtils.create(UserRole)
        }
    }

    suspend fun findOne(id: Int): Role? = dbQuery(database) {
        with (Roles) {
            selectAll().where(this.id eq id).firstOrNull()?.let { resultrow ->
                Role(
                    id = resultrow[this.id].value,
                    name = resultrow[name]
                )
            }
        }
    }

    suspend fun findDefault() : Role = dbQuery(database) {
        with (Roles) {
            var ifrole = select(name eq `role-default`).firstOrNull()?.let {
                Role(
                    id = it[this.id].value,
                    name = it[name]
                )
            }

            if (ifrole == null) {
                val id = insert {
                    it[name] = `role-default`
                } get this.id

                ifrole = findOne(id.value)!!
            }

            ifrole
        }
    }

    suspend fun findAll(): List<Role> = dbQuery(database) {
        with (Roles) {
            selectAll().map {
                Role(
                    id = it[this.id].value,
                    name = it[name]
                )
            }
        }
    }

    suspend fun findAdmin(): Role = dbQuery(database) {
        with (Roles) {
            select(name eq `role-admin`).first().let {
                Role(
                    id = it[this.id].value,
                    name = it[name]
                )
            }
        }
    }
    suspend fun rolesOf(userid: Int): List<Role> = dbQuery(database) {
        val roleids = with (UserRole) {
            selectAll().where(this.userid eq userid)
                .map {
                    it[roleid].value
                }
        }

        with (Roles) {
            selectAll().where(id.inList(roleids))
                .map {
                    Role(
                        id = it[this.id].value,
                        name = it[name]
                    )
                }
        }
    }

    suspend fun insertOne(request: PostRoleRequest): Role = dbQuery(database) {
        val id = with (Roles) {
            insert {
                it[name] = request.name
            } get this.id
        }

        findOne(id.value)!!
    }

    suspend fun clear() {
        dbQuery(database) {
            Roles.deleteAll()
            UserRole.deleteAll()
        }
    }
}