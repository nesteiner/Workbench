package com.steiner.workbench.login.configure

import com.steiner.workbench.login.encoder.MD5PasswordEncoder
import com.steiner.workbench.login.filter.AuthenticationFilter
import com.steiner.workbench.login.filter.LoginFilter
import com.steiner.workbench.login.service.UserService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter

@Configuration
@EnableWebSecurity
@EnableConfigurationProperties(OpenConfigure::class)
class WebSecurityConfigure {
    @Autowired
    fun configureGlobal(authenticationManagerBuilder: AuthenticationManagerBuilder,
                        userService: UserService,
                        mD5PasswordEncoder: MD5PasswordEncoder
                        ) {
        authenticationManagerBuilder
                .userDetailsService(userService)
                .passwordEncoder(mD5PasswordEncoder)
    }

    @Autowired
    lateinit var openConfigure: OpenConfigure

    @Bean
    fun authenticateManager(authenticationConfiguration: AuthenticationConfiguration): AuthenticationManager {
        return authenticationConfiguration.authenticationManager
    }

    @Bean
    fun filterChain(http: HttpSecurity, loginFilter: LoginFilter, authenticateFilter: AuthenticationFilter): SecurityFilterChain {
        http
                .csrf {
                    it.disable()
                }
                .authorizeHttpRequests {
                    it.requestMatchers(*openConfigure.urls).permitAll()
                            .requestMatchers("/admin/**").hasAuthority("admin")

                    it.requestMatchers("/admin/**").hasAuthority("admin")
                    it.requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                    it.anyRequest().authenticated()

                }
                .sessionManagement {
                    it.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                }


        http.addFilterBefore(authenticateFilter, UsernamePasswordAuthenticationFilter::class.java)
        http.addFilterBefore(loginFilter, AuthenticationFilter::class.java)

        return http.build()
    }
}