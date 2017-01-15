package uk.co.danielbryant.exp.helloworld.service;

public class HelloService {

    public String generateHello(final String name, final String currentLocation) {
        return String.format("Hello %s from %s", name, currentLocation);
    }
}
