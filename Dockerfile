# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY DnsChat.csproj .
RUN dotnet restore

# Copy source code and publish
COPY Program.cs .
RUN dotnet publish -c Release -o /app/publish

# Runtime stage - use .NET runtime instead of Alpine
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
WORKDIR /app
COPY --from=build /app/publish .

# Expose DNS port
EXPOSE 53/udp
EXPOSE 53/tcp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD nslookup google.com 127.0.0.1 || exit 1

ENV BIND_ADDRESS=0.0.0.0
ENV DNS_PORT=53

ENTRYPOINT ["dotnet", "DnsChat.dll"]