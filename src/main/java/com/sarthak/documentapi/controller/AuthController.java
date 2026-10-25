
package com.sarthak.documentapi.controller;

import com.sarthak.documentapi.dto.AuthResponse;
import com.sarthak.documentapi.dto.LoginRequest;
import com.sarthak.documentapi.dto.RegisterRequest;
import com.sarthak.documentapi.dto.UserResponse;
import com.sarthak.documentapi.entity.User;
import com.sarthak.documentapi.security.JwtService;
import com.sarthak.documentapi.service.UserService;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserService userService;
    private final JwtService jwtService;

    public AuthController(UserService userService,
                          JwtService jwtService) {
        this.userService = userService;
        this.jwtService = jwtService;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public UserResponse register(
            @Valid @RequestBody RegisterRequest request) {

        User user = userService.registerUser(
                request.getName(),
                request.getEmail(),
                request.getPassword()
        );

        return new UserResponse(
                user.getId(),
                user.getName(),
                user.getEmail()
        );
    }

    @PostMapping("/login")
    public AuthResponse login(
            @Valid @RequestBody LoginRequest request) {

        User user = userService.authenticateUser(
                request.getEmail(),
                request.getPassword()
        );

        String token = jwtService.generateToken(user.getEmail());

        return new AuthResponse(token);
    }
}
