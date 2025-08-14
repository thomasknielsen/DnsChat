function Ask-DNS {
    param([string]$Question, [string]$Server = "127.0.0.1")
    
    $DnsQuestion = $Question.Replace(" ", "-")
    Write-Host "🤖 $Question" -ForegroundColor Cyan
    
    try {
        $result = Resolve-DnsName -Name $DnsQuestion -Type TXT -Server $Server -ErrorAction Stop
        Write-Host "💬 " -ForegroundColor Green -NoNewline
        $result.Strings | ForEach-Object { Write-Host $_ -ForegroundColor White }
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Example usage:
# Ask-DNS "what is artificial intelligence"
# Ask-DNS "tell me a joke"
# Ask-DNS "random science fact"

Write-Host "DNS ChatGPT ready! Use: Ask-DNS 'your question here'" -ForegroundColor Yellow