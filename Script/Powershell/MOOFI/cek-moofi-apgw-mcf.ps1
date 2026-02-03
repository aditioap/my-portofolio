# Define the URL
$url = "https://mobile.mcfz.co.id"

# Try to make a web request
try {
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 404) {
        Write-Host "✅ $url is reachable and returned expected 404 (No route matched)." -ForegroundColor Green
    } else {
        Write-Host "⚠️ $url responded, but with unexpected status code: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    # Some status codes (like 404) can throw exceptions depending on .NET version / PowerShell behavior
    if ($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 404) {
        Write-Host "✅ $url is reachable and returned expected 404 (No route matched)." -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to reach $url or unexpected error." -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor DarkRed
    }
}
