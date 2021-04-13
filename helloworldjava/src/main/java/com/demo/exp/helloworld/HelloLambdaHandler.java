package com.demo.exp.helloworld;


import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.demo.exp.helloworld.service.HelloService;
import com.demo.exp.helloworld.view.Request;
import com.demo.exp.helloworld.view.Response;

public class HelloLambdaHandler implements RequestHandler<Request, Response> {

    private final HelloService helloService;

    public HelloLambdaHandler() {
        this.helloService = new HelloService();
    }

    public Response handleRequest(Request request, Context context) {
        final String name = request.getName();
        final String currentLocation = System.getenv("currentLocation");

        final Response response = new Response(helloService.generateHello(name, currentLocation));
        return response;
    }
}