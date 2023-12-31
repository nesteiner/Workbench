/*
 * This file was generated by the Gradle 'init' task.
 *
 * This is a general purpose Gradle build.
 * To learn more about Gradle by exploring our Samples at https://docs.gradle.org/8.2.1/samples
 */
dependencies {
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    testImplementation("org.springframework.boot:spring-boot-starter-test")

    implementation(project(":common"))
    implementation(project(":login"))
    implementation(project(":todolist"))
    implementation(project(":daily-attendance"))
    implementation(project(":clipboard"))
    implementation(project(":samba"))
    implementation(project(":websocket"))
}

tasks.withType<Test> {
    useJUnitPlatform()
}