function Ask-ChatGPT {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Question,
        [string]$Server = "127.0.0.1"
    )
    
    # Convert spaces to hyphens for DNS compatibility
    $DnsQuery = $Question.Replace(" ", "-")
    
    Write-Host "💬 " -ForegroundColor Cyan -NoNewline
    Write-Host "$Question" -ForegroundColor White
    
    try {
        # Use nslookup with the converted query
        $output = & nslookup -type=txt -timeout=15 "`"$DnsQuery`"" $Server 2>&1
        
        # Parse the response
        $response = ""
        $capturing = $false
        
        foreach ($line in $output) {
            if ($line -match 'text =') {
                $capturing = $true
                continue
            }
            if ($capturing) {
                if ($line -match '^\s*"(.+)"') {
                    $response += $matches[1]
                } elseif ($line -match '^Non-authoritative answer:') {
                    break
                }
            }
        }
        
        if ($response) {
            Write-Host "🤖 " -ForegroundColor Green -NoNewline
            Write-Host $response -ForegroundColor White
        } else {
            Write-Host "❌ No response received" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Make it available globally
Set-Alias -Name "ask" -Value "Ask-ChatGPT"

Write-Host @"
🚀 DNS ChatGPT is ready!

Usage:
  Ask-ChatGPT "what is artificial intelligence"
  ask "tell me a joke"
  ask "random fact of the day"
  ask "how do computers work"

"@ -ForegroundColor Yellow