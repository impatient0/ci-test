package com.example.two;

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
        return "Service TWO (updated): " + messageGenerator.getMessage();
    }
}