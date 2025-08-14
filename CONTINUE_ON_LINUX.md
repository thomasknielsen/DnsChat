# DNS ChatGPT Server - Linux Migration Instructions

## Current Project Status

This is a **DNS server that responds to TXT record queries with ChatGPT responses**. The server is fully functional, but Windows `nslookup` has limitations with natural language queries that Linux `dig` handles properly.

## What's Already Working

✅ **DNS Server**: Fully operational C# .NET 8 DNS server
✅ **Docker Container**: Multi-stage build, runs on port 53
✅ **GPT-4 Integration**: Working with OpenAI API key (set via environment variable)
✅ **Query Parsing**: Converts hyphens to spaces (`tell-me-about-cats` → `"tell me about cats"`)
✅ **Git Repository**: Initialized with proper .gitignore

## Key Files in Project

- `Program.cs` - Main DNS server implementation
- `DnsChat.csproj` - .NET project file  
- `Dockerfile` - Multi-stage container build
- `docker-compose.yml` - Container orchestration
- `CLAUDE.md` - Architecture documentation
- `.gitignore` - Excludes .env files and build artifacts

## Current DNS Server Logic

```csharp
// Key parsing logic in Program.cs:
var domainName = question.Name.ToString().TrimEnd('.');
var questionText = domainName
    .Replace(".mindworking.local", "")  // Remove domain suffix
    .Replace(".", " ")                  // Convert dots to spaces
    .Replace("-", " ");                 // Convert hyphens to spaces

// Sends to GPT-4 with system prompt for concise responses
```

## Issue to Solve on Linux

**Windows Problem**: `nslookup -type=txt "tell me about cats" 127.0.0.1` only sends `"tell"` 
**Linux Solution**: `dig @127.0.0.1 "tell-me-about-cats" TXT` sends full query

## Tasks for Linux Session

1. **Test Current Container**: 
   ```bash
   docker-compose up -d
   dig @127.0.0.1 "tell-me-about-cats" TXT
   ```

2. **Test Natural Language**: Try these queries with `dig`:
   ```bash
   dig @127.0.0.1 "what-is-artificial-intelligence" TXT
   dig @127.0.0.1 "random-fact-of-the-day" TXT  
   dig @127.0.0.1 "tell-me-a-joke" TXT
   ```

3. **Create Linux Helper Script**: Make a bash script that converts spaces to hyphens:
   ```bash
   #!/bin/bash
   ask() {
     query=$(echo "$1" | sed 's/ /-/g')
     dig @127.0.0.1 "$query" TXT +short
   }
   ```

4. **Verify Full Pipeline**: Ensure the complete flow works:
   - Natural language input → Hyphen conversion → DNS query → Server parsing → GPT-4 → Response

## Container Details

- **Image**: Uses .NET 8 Alpine base (~181MB)
- **Ports**: 53/tcp and 53/udp exposed  
- **API Key**: Set via `OPENAI_API_KEY` environment variable
- **Model**: Uses GPT-4 (required for this API key)
- **Responses**: Concise, DNS-friendly format

## Expected Success Criteria

When working correctly on Linux, you should be able to:
```bash
dig @127.0.0.1 "tell-me-about-cats" TXT
# Returns: Detailed information about cats from GPT-4

dig @127.0.0.1 "what-is-2-plus-2" TXT  
# Returns: "4" or "2 plus 2 equals 4"
```

## Architecture Notes

The server follows the same pattern as ch.at:
- Receives DNS TXT queries
- Strips domain suffixes
- Converts separators (dots/hyphens) to spaces
- Sends to LLM
- Returns response as TXT record
- Handles response chunking for DNS size limits

The implementation is production-ready and just needs proper DNS client testing with `dig` on Linux.