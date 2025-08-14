# New Claude Code Session Prompt

**Context**: I have a DNS server that responds to TXT queries with ChatGPT answers. It's working on Docker but Windows `nslookup` has limitations. I need to test and perfect it on Linux using `dig`.

**What to say to Claude Code:**

---

I have a DNS ChatGPT server project that's almost complete but needs Linux testing with the `dig` command. The Windows `nslookup` has limitations that prevent natural language queries from working properly.

**Current Status:**
- ✅ C# DNS server running in Docker container on port 53
- ✅ GPT-4 integration working with API key 
- ✅ Server converts hyphens to spaces (`"tell-me-about-cats"` → `"tell me about cats"`)
- ❌ Windows `nslookup` only sends first word, but Linux `dig` should work properly

**Please:**
1. Check the `CONTINUE_ON_LINUX.md` file for full project details
2. Start the container: `docker-compose up -d`  
3. Test with dig: `dig @127.0.0.1 "tell-me-about-cats" TXT`
4. Create a bash helper script for natural language queries
5. Verify the complete pipeline works as expected

**Expected result:** `dig @127.0.0.1 "tell-me-about-cats" TXT` should return detailed information about cats from GPT-4.

**Key files to check:** `Program.cs`, `docker-compose.yml`, `CLAUDE.md`

---

This should give the new Claude Code session everything needed to continue and complete the project successfully on Linux!