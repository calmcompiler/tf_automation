import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";

export async function httpTrigger(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  context.log(`HTTP trigger function processed a request.`);

  const name = request.query.get("name") || "World";

  return {
    status: 200,
    body: `Hello, ${name}!`,
    headers: {
      "Content-Type": "text/plain",
    },
  };
}

app.http("httpTrigger", {
  methods: ["GET", "POST"],
  authLevel: "anonymous",
  handler: httpTrigger,
});
