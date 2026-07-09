# PowerShell Script to Clean and Zip Lab 10 Projects for Submission

$projects = @(
    "Lab10_1_MockLogin",
    "Lab10_2_RealApiLogin",
    "Lab10_3_AutoLogin_Logout",
    "Lab10_4_FirebaseGoogleSignIn",
    "Lab10_5_Notification",
    "Lab10_Full"
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   LAB 10 ZIP GENERATION AUTOMATOR      " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

foreach ($project in $projects) {
    if (Test-Path $project) {
        Write-Host "Processing project: $project..." -ForegroundColor Yellow
        
        # 1. Clean Flutter build outputs to save space
        Write-Host "  -> Cleaning temporary build files..." -ForegroundColor Gray
        Push-Location $project
        try {
            flutter clean
        } catch {
            Write-Warning "Could not run 'flutter clean' in $project. Proceeding..."
        }
        Pop-Location
        
        # 2. Compress the folder to a .zip archive
        $zipPath = "$project.zip"
        if (Test-Path $zipPath) {
            Write-Host "  -> Removing existing zip: $zipPath" -ForegroundColor DarkGray
            Remove-Item $zipPath -Force
        }
        
        Write-Host "  -> Generating $zipPath..." -ForegroundColor Green
        # Compress-Archive is built into PowerShell
        Compress-Archive -Path $project -DestinationPath $zipPath -Force
        
        $size = (Get-Item $zipPath).Length / 1MB
        Write-Host ("  [SUCCESS] Completed. Size: {0:N2} MB" -f $size) -ForegroundColor Green
    } else {
        Write-Warning "Directory $project does not exist. Skipping."
    }
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Zip packages created successfully.       " -ForegroundColor Cyan
Write-Host " You can submit the 6 .zip files.        " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
