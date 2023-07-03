# Import Clipboard module
Import-Module -Name Microsoft.PowerShell.Management

# Specify the folder to watch
$watchFolder = "D:\manpreet\codes\http\cdn"

# Specify the server URL
$serverUrl = "http://cdn.manpreet.tk:32081"
# $serverUrl = "http://localhost:3000"

# Specify the filename to store uploaded filenames
$uploadedFile = "uploaded.txt"

function send-File($filePath) {
    $fileName = [System.IO.Path]::GetFileName($filePath)
    $fileUrl = $serverUrl + "/files/" + $fileName
    $webClient = New-Object System.Net.WebClient
    $url = $serverUrl + "/upload"
    try {
        $webClient.UploadFile($url, $filePath)
        $uploadedFilenames = Get-Content $uploadedFile
        if (-not ($uploadedFilenames -contains $fileName)) {
            Write-Host "First time upload"
            $uploadedFilenames += $fileName
            $fileUrl = $serverUrl + "/files/" + $fileName
            Write-Host "URL copied to clipboard: $fileUrl"
            Set-Clipboard -Value $fileUrl
            $fileName | Out-File $uploadedFile -Encoding utf8 -Append
        }
    } catch {
        Write-Host "Failed to upload file: $($_.Exception.Message)"
    } finally {
        $webClient.Dispose()
    }
}

function remove-File($fileName) {
    try {
        $url = $serverUrl + "/delete/$fileName"
        Invoke-RestMethod -Uri $url -Method DELETE
        Write-Host "File deleted successfully: $fileName"
        # $uploadedFilenames = Get-Content $uploadedFile
        # $uploadedFilenames = $uploadedFilenames | Where-Object { $_ -ne $fileName }
        # $uploadedFilenames | Out-File $uploadedFile -Encoding utf8 -Force
    } catch {
        Write-Host "Failed to delete file: $fileName"
    }
}

Write-Host "Watching folder: $watchFolder"

while ($true) {
    $uploadedFilenames = Get-Content $uploadedFile
    $files = Get-ChildItem -Path $watchFolder -Filter "*.*" -File

    foreach ($filename in $uploadedFilenames){
        if (-not (Test-Path -path .\cdn\$filename)){
            Remove-File $filename
            $uploadedFilenames = $uploadedFilenames | Where-Object { $_ -ne $filename }
            $uploadedFilenames | Out-File $uploadedFile -Encoding utf8

        }
    }

    foreach ($file in $files) {
        $filePath = $file.FullName
        Write-Host "file: $filePath"
        Send-File $filePath
    }

    Start-Sleep -Seconds 1
}