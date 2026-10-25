warning: in the working copy of 'pom.xml', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'src/main/resources/application.properties', LF will be replaced by CRLF the next time Git touches it
[1mdiff --git a/pom.xml b/pom.xml[m
[1mindex 1370862..039f2ed 100644[m
[1m--- a/pom.xml[m
[1m+++ b/pom.xml[m
[36m@@ -33,10 +33,26 @@[m
 [m
 [m
 		<dependency>[m
[31m-			<groupId>org.springframework.boot</groupId>[m
[31m-			<artifactId>spring-boot-starter-validation</artifactId>[m
[32m+[m			[32m<groupId>io.jsonwebtoken</groupId>[m
[32m+[m			[32m<artifactId>jjwt-api</artifactId>[m
[32m+[m			[32m<version>0.13.0</version>[m
[32m+[m		[32m</dependency>[m
[32m+[m
[32m+[m		[32m<dependency>[m
[32m+[m			[32m<groupId>io.jsonwebtoken</groupId>[m
[32m+[m			[32m<artifactId>jjwt-impl</artifactId>[m
[32m+[m			[32m<version>0.13.0</version>[m
[32m+[m			[32m<scope>runtime</scope>[m
 		</dependency>[m
 [m
[32m+[m		[32m<dependency>[m
[32m+[m			[32m<groupId>io.jsonwebtoken</groupId>[m
[32m+[m			[32m<artifactId>jjwt-jackson</artifactId>[m
[32m+[m			[32m<version>0.13.0</version>[m
[32m+[m			[32m<scope>runtime</scope>[m
[32m+[m		[32m</dependency>[m
[32m+[m
[32m+[m
 		<dependency>[m
 			<groupId>org.springframework.security</groupId>[m
 			<artifactId>spring-security-crypto</artifactId>[m
[36m@@ -51,15 +67,19 @@[m
 			<groupId>org.springframework.boot</groupId>[m
 			<artifactId>spring-boot-starter-security</artifactId>[m
 		</dependency>[m
[32m+[m
 		<dependency>[m
 			<groupId>org.springframework.boot</groupId>[m
[31m-			<artifactId>spring-boot-starter-validation</artifactId>[m
[32m+[m			[32m<artifactId>spring-boot-starter-webmvc</artifactId>[m
 		</dependency>[m
[32m+[m
[32m+[m
 		<dependency>[m
 			<groupId>org.springframework.boot</groupId>[m
[31m-			<artifactId>spring-boot-starter-webmvc</artifactId>[m
[32m+[m			[32m<artifactId>spring-boot-starter-validation</artifactId>[m
 		</dependency>[m
 [m
[32m+[m
 		<dependency>[m
 			<groupId>org.postgresql</groupId>[m
 			<artifactId>postgresql</artifactId>[m
[36m@@ -90,6 +110,10 @@[m
 			<artifactId>spring-boot-starter-webmvc-test</artifactId>[m
 			<scope>test</scope>[m
 		</dependency>[m
[32m+[m		[32m<dependency>[m
[32m+[m			[32m<groupId>org.springframework.boot</groupId>[m
[32m+[m			[32m<artifactId>spring-boot-starter-actuator</artifactId>[m
[32m+[m		[32m</dependency>[m
 	</dependencies>[m
 [m
 	<build>[m
[1mdiff --git a/src/main/java/com/sarthak/documentapi/controller/AuthController.java b/src/main/java/com/sarthak/documentapi/controller/AuthController.java[m
[1mindex d30ee6d..e8778ec 100644[m
[1m--- a/src/main/java/com/sarthak/documentapi/controller/AuthController.java[m
[1m+++ b/src/main/java/com/sarthak/documentapi/controller/AuthController.java[m
[36m@@ -1,11 +1,16 @@[m
 [m
 package com.sarthak.documentapi.controller;[m
 [m
[32m+[m[32mimport com.sarthak.documentapi.dto.AuthResponse;[m
[32m+[m[32mimport com.sarthak.documentapi.dto.LoginRequest;[m
 import com.sarthak.documentapi.dto.RegisterRequest;[m
 import com.sarthak.documentapi.dto.UserResponse;[m
 import com.sarthak.documentapi.entity.User;[m
[32m+[m[32mimport com.sarthak.documentapi.security.JwtService;[m
 import com.sarthak.documentapi.service.UserService;[m
[32m+[m
 import jakarta.validation.Valid;[m
[32m+[m
 import org.springframework.http.HttpStatus;[m
 import org.springframework.web.bind.annotation.*;[m
 [m
[36m@@ -14,9 +19,12 @@[m [mimport org.springframework.web.bind.annotation.*;[m
 public class AuthController {[m
 [m
     private final UserService userService;[m
[32m+[m[32m    private final JwtService jwtService;[m
 [m
[31m-    public AuthController(UserService userService) {[m
[32m+[m[32m    public AuthController(UserService userService,[m
[32m+[m[32m                          JwtService jwtService) {[m
         this.userService = userService;[m
[32m+[m[32m        this.jwtService = jwtService;[m
     }[m
 [m
     @PostMapping("/register")[m
[36m@@ -36,4 +44,18 @@[m [mpublic class AuthController {[m
                 user.getEmail()[m
         );[m
     }[m
[32m+[m
[32m+[m[32m    @PostMapping("/login")[m
[32m+[m[32m    public AuthResponse login([m
[32m+[m[32m            @Valid @RequestBody LoginRequest request) {[m
[32m+[m
[32m+[m[32m        User user = userService.authenticateUser([m
[32m+[m[32m                request.getEmail(),[m
[32m+[m[32m                request.getPassword()[m
[32m+[m[32m        );[m
[32m+[m
[32m+[m[32m        String token = jwtService.generateToken(user.getEmail());[m
[32m+[m
[32m+[m[32m        return new AuthResponse(token);[m
[32m+[m[32m    }[m
 }[m
[1mdiff --git a/src/main/java/com/sarthak/documentapi/dto/AuthResponse.java b/src/main/java/com/sarthak/documentapi/dto/AuthResponse.java[m
[1mindex eb2e90c..f5365b5 100644[m
[1m--- a/src/main/java/com/sarthak/documentapi/dto/AuthResponse.java[m
[1m+++ b/src/main/java/com/sarthak/documentapi/dto/AuthResponse.java[m
[36m@@ -1,4 +1,21 @@[m
[32m+[m
 package com.sarthak.documentapi.dto;[m
 [m
 public class AuthResponse {[m
[32m+[m
[32m+[m[32m    private String token;[m
[32m+[m[32m    private String tokenType;[m
[32m+[m
[32m+[m[32m    public AuthResponse(String token) {[m
[32m+[m[32m        this.token = token;[m
[32m+[m[32m        this.tokenType = "Bearer";[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    public String getToken() {[m
[32m+[m[32m        return token;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    public String getTokenType() {[m
[32m+[m[32m        return tokenType;[m
[32m+[m[32m    }[m
 }[m
[1mdiff --git a/src/main/java/com/sarthak/documentapi/dto/LoginRequest.java b/src/main/java/com/sarthak/documentapi/dto/LoginRequest.java[m
[1mindex dc91354..8de9e50 100644[m
[1m--- a/src/main/java/com/sarthak/documentapi/dto/LoginRequest.java[m
[1m+++ b/src/main/java/com/sarthak/documentapi/dto/LoginRequest.java[m
[36m@@ -1,4 +1,34 @@[m
[32m+[m
 package com.sarthak.documentapi.dto;[m
 [m
[32m+[m[32mimport jakarta.validation.constraints.Email;[m
[32m+[m[32mimport jakarta.validation.constraints.NotBlank;[m
[32m+[m
 public class LoginRequest {[m
[32m+[m
[32m+[m[32m    @NotBlank(message = "Email is required")[m
[32m+[m[32m    @Email(message = "Enter a valid email")[m
[32m+[m[32m    private String email;[m
[32m+[m
[32m+[m[32m    @NotBlank(message = "Password is required")[m
[32m+[m[32m    private String password;[m
[32m+[m
[32m+[m[32m    public LoginRequest() {[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    public String getEmail() {[m
[32m+[m[32m        return email;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    public void setEmail(String email) {[m
[32m+[m[32m        this.email = email;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    public String getPassword() {[m
[32m+[m[32m        return password;[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    public void setPassword(String password) {[m
[32m+[m[32m        this.password = password;[m
[32m+[m[32m    }[m
 }[m
[1mdiff --git a/src/main/java/com/sarthak/documentapi/security/JwtAuthenticationFilter.java b/src/main/java/com/sarthak/documentapi/security/JwtAuthenticationFilter.java[m
[1mindex e5ff0bc..e1aea11 100644[m
[1m--- a/src/main/java/com/sarthak/documentapi/security/JwtAuthenticationFilter.java[m
[1m+++ b/src/main/java/com/sarthak/documentapi/security/JwtAuthenticationFilter.java[m
[36m@@ -1,4 +1,83 @@[m
[32m+[m
 package com.sarthak.documentapi.security;[m
 [m
[31m-public class JwtAuthenticationFilter {[m
[32m+[m[32mimport io.jsonwebtoken.Claims;[m
[32m+[m[32mimport io.jsonwebtoken.JwtException;[m
[32m+[m[32mimport io.jsonwebtoken.Jwts;[m
[32m+[m
[32m+[m[32mimport jakarta.servlet.FilterChain;[m
[32m+[m[32mimport jakarta.servlet.ServletException;[m
[32m+[m[32mimport jakarta.servlet.http.HttpServletRequest;[m
[32m+[m[32mimport jakarta.servlet.http.HttpServletResponse;[m
[32m+[m
[32m+[m[32mimport org.springframework.security.authentication.UsernamePasswordAuthenticationToken;[m
[32m+[m[32mimport org.springframework.security.core.context.SecurityContextHolder;[m
[32m+[m[32mimport org.springframework.security.core.userdetails.User;[m
[32m+[m[32mimport org.springframework.security.web.authentication.WebAuthenticationDetailsSource;[m
[32m+[m[32mimport org.springframework.stereotype.Component;[m
[32m+[m[32mimport org.springframework.web.filter.OncePerRequestFilter;[m
[32m+[m
[32m+[m[32mimport javax.crypto.SecretKey;[m
[32m+[m[32mimport java.io.IOException;[m
[32m+[m
[32m+[m[32m@Component[m
[32m+[m[32mpublic class JwtAuthenticationFilter extends OncePerRequestFilter {[m
[32m+[m
[32m+[m[32m    private final SecretKey signingKey;[m
[32m+[m
[32m+[m[32m    public JwtAuthenticationFilter([m
[32m+[m[32m            @org.springframework.beans.factory.annotation.Value("${app.jwt.secret}")[m
[32m+[m[32m            String secret) {[m
[32m+[m[32m        byte[] keyBytes = io.jsonwebtoken.io.Decoders.BASE64.decode(secret);[m
[32m+[m[32m        this.signingKey = io.jsonwebtoken.security.Keys.hmacShaKeyFor(keyBytes);[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    @Override[m
[32m+[m[32m    protected void doFilterInternal([m
[32m+[m[32m            HttpServletRequest request,[m
[32m+[m[32m            HttpServletResponse response,[m
[32m+[m[32m            FilterChain filterChain)[m
[32m+[m[32m            throws ServletException, IOException {[m
[32m+[m
[32m+[m[32m        String header = request.getHeader("Authorization");[m
[32m+[m
[32m+[m[32m        if (header == null || !header.startsWith("Bearer ")) {[m
[32m+[m[32m            filterChain.doFilter(request, response);[m
[32m+[m[32m            return;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        String token = header.substring(7);[m
[32m+[m
[32m+[m[32m        try {[m
[32m+[m[32m            Claims claims = Jwts.parser()[m
[32m+[m[32m                    .verifyWith(signingKey)[m
[32m+[m[32m                    .build()[m
[32m+[m[32m                    .parseSignedClaims(token)[m
[32m+[m[32m                    .getPayload();[m
[32m+[m
[32m+[m[32m            String email = claims.getSubject();[m
[32m+[m
[32m+[m[32m            if (email != null[m
[32m+[m[32m                    && SecurityContextHolder.getContext().getAuthentication() == null) {[m
[32m+[m
[32m+[m[32m                var authentication = new UsernamePasswordAuthenticationToken([m
[32m+[m[32m                        User.withUsername(email).password("").authorities("ROLE_USER").build(),[m
[32m+[m[32m                        null,[m
[32m+[m[32m                        User.withUsername(email).password("").authorities("ROLE_USER").build()[m
[32m+[m[32m                                .getAuthorities()[m
[32m+[m[32m                );[m
[32m+[m
[32m+[m[32m                authentication.setDetails([m
[32m+[m[32m                        new WebAuthenticationDetailsSource().buildDetails(request));[m
[32m+[m
[32m+[m[32m                SecurityContextHolder.getContext().setAuthentication(authentication);[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m[32m        } catch (JwtException | IllegalArgumentException exception) {[m
[32m+[m[32m            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid or expired JWT");[m
[32m+[m[32m            return;[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        filterChain.doFilter(request, response);[m
[32m+[m[32m    }[m
 }[m
[1mdiff --git a/src/main/java/com/sarthak/documentapi/security/JwtService.java b/src/main/java/com/sarthak/documentapi/security/JwtService.java[m
[1mindex 2f15f65..a40e8ac 100644[m
[1m--- a/src/main/java/com/sarthak/documentapi/security/JwtService.java[m
[1m+++ b/src/main/java/com/sarthak/documentapi/security/JwtService.java[m
[36m@@ -1,4 +1,34 @@[m
[32m+[m
 package com.sarthak.documentapi.security;[m
 [m
[32m+[m[32mimport io.jsonwebtoken.Jwts;[m
[32m+[m[32mimport io.jsonwebtoken.io.Decoders;[m
[32m+[m[32mimport io.jsonwebtoken.security.Keys;[m
[32m+[m[32mimport org.springframework.beans.factory.annotation.Value;[m
[32m+[m[32mimport org.springframework.stereotype.Service;[m
[32m+[m
[32m+[m[32mimport javax.crypto.SecretKey;[m
[32m+[m[32mimport java.util.Date;[m
[32m+[m
[32m+[m[32m@Service[m
 public class JwtService {[m
[32m+[m
[32m+[m[32m    private final SecretKey signingKey;[m
[32m+[m
[32m+[m[32m    public JwtService(@Value("${app.jwt.secret}") String secret) {[m
[32m+[m[32m        byte[] keyBytes = Decoders.BASE64.decode(secret);[m
[32m+[m[32m        this.signingKey = Keys.hmacShaKeyFor(keyBytes);[m
[32m+[m[32m    }[m
[32m+[m
[32m+[m[32m    public String generateToken(String email) {[m
[32m+[m[32m        Date now = new Date();[m
[32m+[m[32m        Date expiration = new Date(now.getTime() + 86400000L);[m
[32m+[m
[32m+[m[32m        return Jwts.builder()[m
[32m+[m[32m                .subject(email)[m
[32m+[m[32m                .issuedAt(now)[m
[32m+[m[32m                .expiration(expiration)[m
[32m+[m[32m                .signWith(signingKey)[m
[32m+[m[32m                .compact();[m
[32m+[m[32m    }[m
 }[m
[1mdiff --git a/src/main/java/com/sarthak/documentapi/security/SecurityConfig.java b/src/main/java/com/sarthak/documentapi/security/SecurityConfig.java[m
[1mindex fc6fca4..e8e514d 100644[m
[1m--- a/src/main/java/com/sarthak/documentapi/security/SecurityConfig.java[m
[1m+++ b/src/main/java/com/sarthak/documentapi/security/SecurityConfig.java[m
[36m@@ -4,23 +4,42 @@[m [mpackage com.sarthak.documentapi.security;[m
 import org.springframework.context.annotation.Bean;[m
 import org.springframework.context.annotation.Configuration;[m
 import org.springframework.security.config.annotation.web.builders.HttpSecurity;[m
[32m+[m[32mimport org.springframework.security.config.http.SessionCreationPolicy;[m
 import org.springframework.security.web.SecurityFilterChain;[m
[32m+[m[32mimport org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;[m
 import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;[m
 import org.springframework.security.crypto.password.PasswordEncoder;[m
 [m
[31m-[m
 @Configuration[m
 public class SecurityConfig {[m
 [m
[32m+[m[32m    private final JwtAuthenticationFilter jwtAuthenticationFilter;[m
[32m+[m
[32m+[m[32m    public SecurityConfig(JwtAuthenticationFilter jwtAuthenticationFilter) {[m
[32m+[m[32m        this.jwtAuthenticationFilter = jwtAuthenticationFilter;[m
[32m+[m[32m    }[m
[32m+[m
     @Bean[m
     public SecurityFilterChain securityFilterChain(HttpSecurity http)[m
             throws Exception {[m
 [m
         http[m
                 .csrf(csrf -> csrf.disable())[m
[32m+[m[32m                .formLogin(form -> form.disable())[m
[32m+[m[32m                .httpBasic(basic -> basic.disable())[m
[32m+[m[32m                .sessionManagement(session ->[m
[32m+[m[32m                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))[m
                 .authorizeHttpRequests(auth -> auth[m
[31m-                        .requestMatchers("/hello","/api/auth/register").permitAll()[m
[32m+[m[32m                        .requestMatchers([m
[32m+[m[32m                                "/hello",[m
[32m+[m[32m                                "/api/auth/register",[m
[32m+[m[32m                                "/api/auth/login"[m
[32m+[m[32m                        ).permitAll()[m
                         .anyRequest().authenticated()[m
[32m+[m[32m                )[m
[32m+[m[32m                .addFilterBefore([m
[32m+[m[32m                        jwtAuthenticationFilter,[m
[32m+[m[32m                        UsernamePasswordAuthenticationFilter.class[m
                 );[m
 [m
         return http.build();[m
[1mdiff --git a/src/main/java/com/sarthak/documentapi/service/UserService.java b/src/main/java/com/sarthak/documentapi/service/UserService.java[m
[1mindex 7f117e1..f35f869 100644[m
[1m--- a/src/main/java/com/sarthak/documentapi/service/UserService.java[m
[1m+++ b/src/main/java/com/sarthak/documentapi/service/UserService.java[m
[36m@@ -37,5 +37,19 @@[m [mpublic class UserService {[m
 [m
         return userRepository.save(user);[m
     }[m
[32m+[m
[32m+[m[32m    public User authenticateUser(String email, String rawPassword) {[m
[32m+[m[32m        String normalizedEmail = email.trim().toLowerCase(Locale.ROOT);[m
[32m+[m
[32m+[m[32m        User user = userRepository.findByEmail(normalizedEmail)[m
[32m+[m[32m                .orElseThrow(() ->[m
[32m+[m[32m                        new IllegalArgumentException("Invalid email or password"));[m
[32m+[m
[32m+[m[32m        if (!passwordEncoder.matches(rawPassword, user.getPassword())) {[m
[32m+[m[32m            throw new IllegalArgumentException("Invalid email or password");[m
[32m+[m[32m        }[m
[32m+[m
[32m+[m[32m        return user;[m
[32m+[m[32m    }[m
 }[m
 [m
[1mdiff --git a/src/main/resources/application.properties b/src/main/resources/application.properties[m
[1mindex c2313b0..73ba1be 100644[m
[1m--- a/src/main/resources/application.properties[m
[1m+++ b/src/main/resources/application.properties[m
[36m@@ -8,3 +8,5 @@[m [mspring.jpa.hibernate.ddl-auto=update[m
 spring.jpa.show-sql=true[m
 spring.jpa.properties.hibernate.format_sql=true[m
 [m
[32m+[m[32mapp.jwt.secret=${JWT_SECRET}[m
[32m+[m
