package com.steiner.workbench.login.service

import com.steiner.workbench.common.util.Page
import com.steiner.workbench.login.model.Role
import com.steiner.workbench.login.request.PostRoleRequest
import com.steiner.workbench.login.request.UpdateRoleRequest
import com.steiner.workbench.login.table.Roles
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.select
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.update
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import kotlin.math.ceil

@Service
@Transactional
class RoleService {
    companion object {
        const val DEFAULT_ROLE_NAME = "user";
    }

    fun insertOne(request: PostRoleRequest): Role {
        val roleid = Roles.insert {
            it[name] = request.name
        } get Roles.id

        return Role(roleid.value, request.name)
    }

    fun updateOne(request: UpdateRoleRequest): Role {
        Roles.update({ Roles.id eq request.id }) {
            it[name] = request.name
        }

        return Role(request.id, request.name)
    }

    fun findOne(id: Int): Role? {
        return Roles.select(Roles.id eq id)
                .firstOrNull()?.let {
                    Role(it[Roles.id].value, it[Roles.name])
                }
    }

    fun findOne(name: String): Role? {
        return Roles.select(Roles.name eq name)
                .firstOrNull()?.let {
                    Role(it[Roles.id].value, it[Roles.name])
                }
    }

    fun findDefault(): Role {
        var role = findOne(DEFAULT_ROLE_NAME)
        if (role == null) {
            role = insertOne(PostRoleRequest(DEFAULT_ROLE_NAME))
        }

        return role
    }

    fun findAll(): List<Role> {
        return Roles.selectAll()
                .map {
                    Role(it[Roles.id].value, it[Roles.name])
                }
    }

    fun findAll(page: Int, size: Int): Page<Role> {
        val content = Roles.selectAll()
                .limit(size, offset = page * size.toLong())
                .map {
                    Role(it[Roles.id].value, it[Roles.name])
                }

        val totalPages = ceil(Roles.selectAll().count() / size.toDouble()).toInt()

        return Page(content, totalPages)
    }
}