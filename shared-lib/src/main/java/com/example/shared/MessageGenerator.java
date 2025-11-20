package com.example.shared;

import org.springframework.stereotype.Service;

@Service
public class MessageGenerator {
    public String getMessage() {
        return "Hello from Shared Lib (v1)";
    }
}