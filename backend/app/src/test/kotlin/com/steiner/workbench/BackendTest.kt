package com.steiner.workbench

import com.steiner.workbench.login.model.Role
import com.steiner.workbench.login.model.User
import com.steiner.workbench.login.table.Roles
import com.steiner.workbench.login.table.UserRole
import com.steiner.workbench.login.table.Users
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.junit.jupiter.api.Test

class BackendTest {
    @Test
    fun injectFakeData() {
        Database.connect(url = "jdbc:postgresql://localhost/workbench", driver = "org.postgresql.Driver", user = "steiner", password = "779151714")

        transaction {
            addLogger(StdOutSqlLogger)
            SchemaUtils.create(Roles, Users, UserRole)

            val roles = listOf(
                    Role(id = 1, name = "admin"),
                    Role(id = 2, name = "user")
            )

            roles.forEach { role ->
                Roles.insert {
                    it[id] = role.id
                    it[name] = role.name
                }
            }

            val admin = User(
                    id = 1,
                    name = "admin",
                    passwordHash = "5f4dcc3b5aa765d61d8327deb882cf99",
                    roles = listOf(roles[0]),
                    enabled = true,
                    email = "steiner3044@163.com"
            )

            Users.insert {
                it[id] = admin.id
                it[name] = admin.name
                it[passwordHash] = admin.passwordHash
                it[enabled] = admin.enabled
                it[email] = admin.email
            }

            UserRole.insert {
                it[userid] = admin.id
                it[roleid] = admin.roles[0].id
            }
        }

    }
}