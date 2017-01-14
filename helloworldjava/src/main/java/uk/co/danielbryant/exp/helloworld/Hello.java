package uk.co.danielbryant.exp.helloworld;


import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import uk.co.danielbryant.exp.helloworld.view.Request;
import uk.co.danielbryant.exp.helloworld.view.Response;

public class Hello implements RequestHandler<Request, Response> {

    public Response handleRequest(Request request, Context context) {
        Response response = new Response();
        response.setOutput(String.format("Hello %s.", request.getName()));
        return response;
    }
}