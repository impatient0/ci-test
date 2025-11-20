package com.example.one;

import com.example.shared.MessageGenerator;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class Controller {

    private final MessageGenerator messageGenerator;

    @GetMapping("/")
    public String hello() {
        return "Service ONE: " + messageGenerator.getMessage();
    }
}