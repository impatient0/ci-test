package com.example.two;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = "com.example")
public class ServiceOneApplication {
    public static void main(String[] args) {
        SpringApplication.run(ServiceOneApplication.class, args);
    }
}