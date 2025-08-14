param(
    [Parameter(Mandatory=$true)]
    [string]$Question,
    
    [string]$Server = "127.0.0.1",
    [int]$Timeout = 15
)

# Convert spaces to hyphens for DNS compatibility
$DnsQuestion = $Question.Replace(" ", "-")

Write-Host "Asking: '$Question'" -ForegroundColor Cyan
Write-Host "DNS query: '$DnsQuestion'" -ForegroundColor Gray

try {
    # Use Resolve-DnsName for better PowerShell integration
    $result = Resolve-DnsName -Name $DnsQuestion -Type TXT -Server $Server -ErrorAction Stop
    
    Write-Host "`nAnswer:" -ForegroundColor Green
    foreach ($record in $result.Strings) {
        Write-Host $record -ForegroundColor White
    }
} catch {
    Write-Host "`nError: $($_.Exception.Message)" -ForegroundColor Red
    
    # Fallback to nslookup
    Write-Host "Trying fallback method..." -ForegroundColor Yellow
    $output = & nslookup -type=txt -timeout=$Timeout "`"$DnsQuestion`"" $Server 2>&1
    
    # Parse nslookup output
    $inAnswer = $false
    foreach ($line in $output) {
        if ($line -match "text =") {
            $inAnswer = $true
            continue
        }
        if ($inAnswer -and $line -match '^\s*"(.+)"') {
            Write-Host $matches[1] -ForegroundColor White
        }
    }
}