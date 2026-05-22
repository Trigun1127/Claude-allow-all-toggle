$scriptFolder = $PSScriptRoot
$scriptName   = "AutoYesToggle.pyw"
$shortcutName = "Claude Permissions.lnk"

$fullScriptPath = Join-Path $scriptFolder $scriptName
$ws = New-Object -ComObject WScript.Shell
$desktop = $ws.SpecialFolders("Desktop")
$shortcutPath = Join-Path $desktop $shortcutName

if (-not (Test-Path $fullScriptPath)) {
    Write-Error "Cannot find '$scriptName' in the current folder: $scriptFolder"
    return
}

# Find pythonw.exe
$pythonw = (Get-Command pythonw.exe -ErrorAction SilentlyContinue).Source
if (-not $pythonw) {
    $python = (Get-Command python.exe -ErrorAction SilentlyContinue).Source
    if ($python) {
        $pythonw = $python -replace 'python\.exe$', 'pythonw.exe'
    } else {
        Write-Error "Python executable not found in PATH."
        return
    }
}

$s = $ws.CreateShortcut($shortcutPath)
$s.TargetPath = $pythonw
$s.Arguments = "`"$fullScriptPath`""
$s.WorkingDirectory = $scriptFolder
$s.Description = 'Claude Code Permissions Toggle'
$s.Save()

Write-Host "Success!" -ForegroundColor Green
Write-Host "Shortcut created on Desktop."
Write-Host "Folder: $scriptFolder"
Write-Host "Target: $pythonw"