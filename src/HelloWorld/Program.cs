using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;
using Amazon.Lambda.RuntimeSupport;
using Amazon.Lambda.Serialization.SystemTextJson;

namespace HelloWorld;

public static class Program
{
    private static async Task Main(string[] args)
    {
        Func<APIGatewayProxyRequest, ILambdaContext, APIGatewayProxyResponse> handler = new Function().FunctionHandler;

        using var handlerWrapper = HandlerWrapper.GetHandlerWrapper(handler, new DefaultLambdaJsonSerializer());
        using var bootstrap = new LambdaBootstrap(handlerWrapper);

        await bootstrap.RunAsync();
    }
}
