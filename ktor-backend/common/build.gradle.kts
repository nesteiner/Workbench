val koin_version: String by project
val ktor_version: String by project
val kotlin_version: String by project
val logback_version: String by project
val postgres_version: String by project
val exposed_version: String by project
val kotlin_datetime_version: String by project

dependencies {
    api("io.ktor:ktor-server-core-jvm")
    api("io.ktor:ktor-server-websockets-jvm")
    api("io.ktor:ktor-server-cors-jvm")
    api("io.ktor:ktor-server-host-common-jvm")
    api("io.ktor:ktor-server-status-pages-jvm")
    api("io.ktor:ktor-serialization-kotlinx-json-jvm")
    api("io.ktor:ktor-server-request-validation")
    api("io.ktor:ktor-server-content-negotiation-jvm")
    api("org.postgresql:postgresql:$postgres_version")
    api("org.jetbrains.exposed:exposed-core:$exposed_version")
    api("org.jetbrains.exposed:exposed-jdbc:$exposed_version")
    api("org.jetbrains.exposed:exposed-json:$exposed_version")
    api("org.jetbrains.exposed:exposed-kotlin-datetime:$exposed_version")
    api("io.ktor:ktor-server-auth-jvm")
    api("io.ktor:ktor-server-auth-jwt-jvm")
    api("io.ktor:ktor-server-cio-jvm")
    api("ch.qos.logback:logback-classic:$logback_version")
    api("io.ktor:ktor-server-config-yaml:2.3.7")
    api("io.insert-koin:koin-ktor:$koin_version")
    api("org.jetbrains.kotlinx:kotlinx-datetime:$kotlin_datetime_version")

    testImplementation("io.ktor:ktor-server-tests-jvm")
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit:$kotlin_version")
}
