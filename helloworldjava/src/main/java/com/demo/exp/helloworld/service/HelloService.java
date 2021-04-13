package com.demo.exp.helloworld.service;

public class HelloService {

    public String generateHello(final String name, final String currentLocation) {
        System.out.println("Version 6");
        return String.format("Hello %s from %s", name, currentLocation);
    }
}
