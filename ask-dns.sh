#!/bin/bash

# DNS ChatGPT Query Helper Script
# Converts natural language queries to DNS-friendly format and queries the server

ask() {
    if [ $# -eq 0 ]; then
        echo "Usage: ask \"your question here\""
        echo "Example: ask \"tell me about cats\""
        return 1
    fi
    
    # Convert spaces to hyphens for DNS compatibility
    query=$(echo "$1" | sed 's/ /-/g')
    
    echo "Querying: $query"
    echo "----------------------------------------"
    
    # Query the DNS server on port 8053 and extract just the TXT record content
    dig @127.0.0.1 -p 8053 "$query" TXT +short | sed 's/^"//;s/"$//'
}

# Export the function so it can be used in the current shell
# Usage: source ./ask-dns.sh, then: ask "tell me about cats"
echo "DNS ChatGPT helper loaded!"
echo "Usage: ask \"your question here\""
echo "Example: ask \"what is artificial intelligence\""
echo "Note: Server is running on port 8053"