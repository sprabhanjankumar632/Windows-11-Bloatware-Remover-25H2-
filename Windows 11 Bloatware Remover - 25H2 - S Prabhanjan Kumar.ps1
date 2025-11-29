# Debloat-Windows.ps1
# Removes all bloatware apps except Store, Notepad, Snip Tool, etc.
# Run as Administrator

# --- Self-bootstrap with NoProfile + Bypass ---
if ($PSCommandPath -and -not $env:DEBLOAT_BOOTSTRAPPED) {
    $env:DEBLOAT_BOOTSTRAPPED = "1"
    Start-Process PowerShell -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy Bypass",
        "-File `"$PSCommandPath`""
    ) -Verb RunAs
    exit
}

# --- Actual script starts here ---

# List of app DisplayNames to KEEP
$appsToKeep = @(
    "Microsoft.WindowsStore",
    "Microsoft.StorePurchaseApp",
    "Microsoft.DesktopAppInstaller",
    "Microsoft.WindowsNotepad",
    "Microsoft.ScreenSketch",
    "Microsoft.WindowsCalculator",
    "Microsoft.Windows.Photos",
    "Microsoft.Paint",
    "Microsoft.WindowsCamera",
    "Microsoft.SecHealthUI",
    "Microsoft.XboxIdentityProvider"
)

Write-Host "`n=== Removing Provisioned Apps (for all future users) ===`n"

# Remove provisioned apps (for new users)
Get-AppxProvisionedPackage -Online | ForEach-Object {
    if ($appsToKeep -notcontains $_.DisplayName) {
        Write-Host "Removing provisioned app: $($_.DisplayName)"
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue
    } else {
        Write-Host "Keeping: $($_.DisplayName)"
    }
}

Write-Host "`n=== Removing Apps for Current User ===`n"

# Remove installed apps for current user
Get-AppxPackage | ForEach-Object {
    if ($appsToKeep -notcontains $_.Name) {
        Write-Host "Removing current user app: $($_.Name)"
        Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue
    } else {
        Write-Host "Keeping: $($_.Name)"
    }
}

Write-Host "`n✅ Debloating Complete!"
