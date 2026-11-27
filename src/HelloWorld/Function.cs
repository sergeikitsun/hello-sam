using System.Text.Json;
using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;

namespace HelloWorld;

public class Function
{
    public APIGatewayProxyResponse FunctionHandler(APIGatewayProxyRequest request, ILambdaContext context)
    {
        var name = ResolveName(request);

        context.Logger.LogInformation($"Received hello request for '{name}'");

        var body = JsonSerializer.Serialize(new { Message = $"Hello, {name}!" });

        return new APIGatewayProxyResponse
        {
            StatusCode = 200,
            Headers = new Dictionary<string, string>
            {
                ["Content-Type"] = "application/json",
                ["Access-Control-Allow-Origin"] = "*"
            },
            Body = body
        };
    }

    private static string ResolveName(APIGatewayProxyRequest request)
    {
        if (request?.QueryStringParameters != null &&
            request.QueryStringParameters.TryGetValue("name", out var fromQuery) &&
            !string.IsNullOrWhiteSpace(fromQuery))
        {
            return fromQuery;
        }

        if (!string.IsNullOrWhiteSpace(request?.Body))
        {
            try
            {
                var parsed = JsonSerializer.Deserialize<Dictionary<string, string>>(request.Body);
                if (parsed != null &&
                    parsed.TryGetValue("name", out var fromBody) &&
                    !string.IsNullOrWhiteSpace(fromBody))
                {
                    return fromBody;
                }
            }
            catch (JsonException)
            {
                // Ignore malformed JSON and fall back to the default name.
            }
        }

        return "World";
    }
}
