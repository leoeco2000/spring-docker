package com.lemon.springdocker.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SampleController {

  @GetMapping(value = "/")
  public String home(){
    return "Hello Docker World";
  }
}