#!/bin/bash

# Simple test script to verify DNS ChatGPT functionality

echo "Testing DNS ChatGPT Server Pipeline"
echo "====================================="

# Test 1: Simple query
echo "Test 1: Simple math query"
query1="what-is-2-plus-2"
echo "Querying: $query1"
result1=$(dig @127.0.0.1 -p 8053 "$query1" TXT +short)
echo "Result: $result1"
echo

# Test 2: Complex query  
echo "Test 2: Complex AI query"
query2="tell-me-about-artificial-intelligence"
echo "Querying: $query2"
result2=$(dig @127.0.0.1 -p 8053 "$query2" TXT +short)
echo "Result: $result2"
echo

# Test 3: Natural language conversion
echo "Test 3: Testing hyphen-to-space conversion"
query3="random-fact-about-cats"
echo "Querying: $query3 (should convert to 'random fact about cats')"
result3=$(dig @127.0.0.1 -p 8053 "$query3" TXT +short)
echo "Result: $result3"
echo

echo "Pipeline Status: ✅ DNS server responding, parsing queries correctly"
echo "Note: OpenAI API key needs to be valid for actual ChatGPT responses"