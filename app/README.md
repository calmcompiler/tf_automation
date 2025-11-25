# Azure Function App - Hello World

Node.js + TypeScript HTTP-triggered Azure Function that returns "Hello, [name]!" with a configurable name parameter.

## Local Development

### Prerequisites
- Node.js 18+ and npm
- Azure Functions Core Tools (`npm install -g azure-functions-core-tools@4`)

### Setup
```bash
cd app
npm install
npm run build
npm start
```

### Test Locally
```bash
curl "http://localhost:7071/api/httpTrigger?name=YourName"
# Returns: Hello, YourName!
```

## Deployment
See `/infrastructure/README.md` for Terraform-based deployment instructions.
