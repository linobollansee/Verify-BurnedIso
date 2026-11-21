# Prompt for inputs and clean them up
$driveInput = (Read-Host "Enter your optical drive letter (e.g., D)").Trim().TrimEnd(':').ToUpper()
$bytesInput = (Read-Host "Enter the exact ISO size in bytes (e.g., 6842105856)") -replace '[^\d]', ''

$drive = "\\.\$($driveInput):"
$isoBytes = [int64]$bytesInput

Write-Host "`nReading $isoBytes bytes from $drive... Please wait." -ForegroundColor Cyan

$stream = [System.IO.File]::OpenRead($drive)
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$buffer = New-Object byte[] 1048576
$remaining = $isoBytes

try {
    while ($remaining -gt 0) {
        $toRead = [int][Math]::Min([int64]$buffer.Length, $remaining)
        $read = $stream.Read($buffer, 0, $toRead)
        if ($read -le 0) { break }
        $sha256.TransformBlock($buffer, 0, $read, $null, 0) | Out-Null
        $remaining -= $read
    }

    $sha256.TransformFinalBlock($buffer, 0, 0) | Out-Null
    $hash = ([BitConverter]::ToString($sha256.Hash)).Replace("-", "")

    Write-Host "`nCalculated SHA-256:" -ForegroundColor Green
    Write-Host $hash
}
finally {
    $stream.Close()
    $sha256.Dispose()
}
