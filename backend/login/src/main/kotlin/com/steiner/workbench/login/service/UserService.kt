package com.steiner.workbench.login.service

import com.steiner.workbench.common.exception.BadRequestException
import com.steiner.workbench.common.util.Page
import com.steiner.workbench.login.model.Role
import com.steiner.workbench.login.model.User
import com.steiner.workbench.login.request.PostUserRequest
import com.steiner.workbench.login.request.UpdateUserRequest
import com.steiner.workbench.login.table.Roles
import com.steiner.workbench.login.table.UserRole
import com.steiner.workbench.login.table.Users
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.springframework.security.core.userdetails.User as OtherUser
import kotlin.math.ceil

@Service
@Transactional
class UserService: UserDetailsService {
    override fun loadUserByUsername(username: String): UserDetails {
        val ifuser = findOne(username)
        return if (ifuser != null) {
            val authorities = ifuser.roles.map {
                SimpleGrantedAuthority(it.name)
            }

            OtherUser(ifuser.name, ifuser.passwordHash, authorities)
        } else {
            throw UsernameNotFoundException("no such user: $username")
        }
    }

    fun findOne(id: Int): User? {
        val roleids = Users.join(
                UserRole,
                joinType = JoinType.INNER,
                onColumn = Users.id,
                otherColumn = UserRole.userid
        ).select(UserRole.userid eq id)
                .map {
                    it[UserRole.roleid]
                }

        val roles = Roles.select(Roles.id.inList(roleids))
                .map {
                    Role(it[Roles.id].value, it[Roles.name])
                }

        return Users.select(Users.id eq id)
                .firstOrNull()?.let {
                    User(
                            it[Users.id].value,
                            it[Users.name],
                            roles,
                            it[Users.email],
                            it[Users.enabled],
                            it[Users.passwordHash]
                    )
                }
    }

    fun findOne(name: String): User? {
        val roleids = Users.join(
                UserRole,
                joinType = JoinType.INNER,
                onColumn = Users.id,
                otherColumn = UserRole.userid
        ).select(Users.name eq name)
                .map {
                    it[UserRole.roleid]
                }

        val roles = Roles.select(Roles.id.inList(roleids))
                .map {
                    Role(it[Roles.id].value, it[Roles.name])
                }

        return Users.select(Users.name eq name)
                .firstOrNull()?.let {
                    User(
                            it[Users.id].value,
                            it[Users.name],
                            roles,
                            it[Users.email],
                            it[Users.enabled],
                            it[Users.passwordHash]
                    )
                }
    }

    fun findAll(): List<User> {
        return Users.selectAll()
                .map {
                    val userid = it[Users.id]
                    val roleids = Users.join(
                            UserRole,
                            joinType = JoinType.INNER,
                            onColumn = Users.id,
                            otherColumn = UserRole.userid
                    ).select(UserRole.userid eq userid)
                            .map {
                                it[UserRole.roleid]
                            }

                    val roles = Roles.select(Roles.id.inList(roleids))
                            .map {
                                Role(it[Roles.id].value, it[Roles.name])
                            }

                    User(
                            it[Users.id].value,
                            it[Users.name],
                            roles,
                            it[Users.email],
                            it[Users.enabled],
                            it[Users.passwordHash]
                    )
                }
    }

    fun findAll(page: Int, size: Int): Page<User> {
        val content = Users.selectAll()
                .limit(size, offset = page * size.toLong())
                .map {
                    val userid = it[Users.id]
                    val roleids = Users.join(
                            UserRole,
                            joinType = JoinType.INNER,
                            onColumn = Users.id,
                            otherColumn = UserRole.userid
                    ).select(UserRole.userid eq userid)
                            .map {
                                it[UserRole.roleid]
                            }

                    val roles = Roles.select(Roles.id.inList(roleids))
                            .map {
                                Role(it[Roles.id].value, it[Roles.name])
                            }

                    User(
                            it[Users.id].value,
                            it[Users.name],
                            roles,
                            it[Users.email],
                            it[Users.enabled],
                            it[Users.passwordHash]
                    )
                }

        val totalPages = ceil(Users.selectAll().count() / size.toDouble()).toInt()

        return Page(content, totalPages)
    }

    fun deleteOne(id: Int) {
        UserRole.deleteWhere {
            userid eq id
        }

        Users.deleteWhere {
            Users.id eq id
        }
    }

    fun updateOne(request: UpdateUserRequest, id: Int): User {
        Users.update({Users.id eq id}) {
            if (request.name != null) {
                it[name] = request.name
            }

            if (request.email != null) {
                it[email] = request.email
            }

            if (request.roles != null) {
                val size = request.roles.size.toLong()
                val count = UserRole.select(UserRole.roleid.inList(request.roles.map { it.id })).count()

                if (size != count) {
                    throw BadRequestException("there is unmatched roles")
                }

                UserRole.deleteWhere {
                    userid eq id
                }

                for (role in request.roles) {
                    UserRole.insert {
                        it[userid] = id
                        it[roleid] = role.id
                    }
                }
            }

            if (request.email != null) {
                it[email] = request.email
            }

            if (request.enabled != null) {
                it[enabled] = request.enabled
            }
        }

        return findOne(id) ?: throw BadRequestException("no such user with id: $id")
    }

    fun insertOne(request: PostUserRequest): User {
        val user = findOne(request.name)

        return if (user == null) {
            val userid = Users.insert {
                it[name] = request.name
                it[email] = request.email
                it[passwordHash] = request.passwordHash
                it[enabled] = request.enabled
            } get Users.id

            request.roles.forEach { role ->
                UserRole.insert {
                    it[UserRole.userid] = userid
                    it[roleid] = role.id
                }
            }

            findOne(request.name)!!
        } else {
            throw BadRequestException("username duplicate")
        }
    }

    fun currentUserId(): Int {
        val userdetail = SecurityContextHolder.getContext().authentication
        val username = userdetail.name
        return findOne(username)!!.id
    }
}