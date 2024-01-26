plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "0.5.0"
}
rootProject.name = "ktor-backend"
include("app")
include("common")
include("login")
include("todolist")
