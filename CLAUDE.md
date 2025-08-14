# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **DNS server that responds to TXT record queries with ChatGPT responses**. When a DNS TXT query is made, the server forwards the domain name as a question to OpenAI's ChatGPT API and returns the response as a TXT record.

### Architecture

- **Single-file application** (`Program.cs`) - All logic in one file using top-level statements
- **ARSoft.Tools.Net library** - Handles DNS protocol operations and server functionality
- **Event-driven DNS processing** - Uses `QueryReceived` event handler for incoming DNS queries
- **Asynchronous OpenAI API calls** - Each TXT query triggers an HTTP request to ChatGPT
- **TXT record chunking** - Long responses are automatically split into 255-byte chunks as per DNS TXT record requirements

### Key Components

1. **DNS Server Setup** (`Program.cs:19`) - Creates DnsServer instance with configurable bind address and port
2. **Query Handler** (`Program.cs:20-46`) - Processes only TXT record types, calls ChatGPT, and builds DNS response
3. **OpenAI Integration** (`AskChatGpt` function) - Makes HTTP requests to ChatGPT API with error handling
4. **Text Chunking** (`SplitTextIntoChunks` function) - Splits responses to comply with DNS TXT record size limits

## Development Commands

### Local Development
```bash
# Build and run locally
dotnet restore
dotnet run

# Build release version
dotnet publish -c Release
```

### Docker Operations
```bash
# Build container
docker-compose build

# Run container (detached)
docker-compose up -d

# View logs
docker logs dnschat-dnschat-1

# Stop container
docker-compose down

# Rebuild and restart
docker-compose down && docker-compose build && docker-compose up -d
```

### Testing the DNS Server
```bash
# Test TXT queries (replace 127.0.0.1 with container IP if needed)
nslookup -type=txt "what is 2+2" 127.0.0.1
nslookup -type=txt "weather in Paris" 127.0.0.1

# Check container status
docker ps
```

## Environment Configuration

**Required**: `OPENAI_API_KEY` - Set in `.env` file (copy from `.env.example`)
**Optional**: `DNS_PORT` (default: 53), `BIND_ADDRESS` (default: 0.0.0.0)

The server will respond with error messages if the API key is missing or invalid.

## Docker Architecture

- **Multi-stage build** - SDK image for building, ASP.NET runtime image for execution
- **Port 53 binding** - Requires `NET_BIND_SERVICE` capability in docker-compose.yml
- **Security hardening** - Read-only filesystem, no-new-privileges, tmpfs for temporary files
- **Health checks** - Built-in DNS health check using nslookup

## Troubleshooting

- Container restart loops usually indicate console input issues (ensure no `Console.ReadKey()` calls)
- "API Error: Unauthorized" means invalid/missing OpenAI API key
- Port 53 binding issues require running with appropriate privileges or using alternative ports
- Long ChatGPT responses are automatically chunked, but very long responses may still cause issues