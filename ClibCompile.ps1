



$CFiles = [System.Collections.ArrayList]@()
$CFilesWithIndex = [System.Collections.ArrayList]@()
#$pattern = '^[a-zA-Z]:\\(?:[^\\/:*?"<>|\r\n]+\\)*[^\\/:*?"<>|\r\n]*$'
$Files = "empty"
$ContinueCompile = ""
$Spaces = " " * 50
$Spinner = 


while ($true){
    $CFolderPath = Read-Host "Please enter your C Folder Path"
    if (Test-path $CFolderPath) {
        $Files =  Get-ChildItem $CFolderPath
        # Get-Member -InputObject $Files[1]
        foreach ($file in $Files){
            if (-not ($file.PSIsContainer) -and $file.Name -match "\.c$"){
                [void]$CFiles.Add($file.Name)
            }
        }
        break
    } else {
        Write-Host "Error: This path is invalid. Please try again." -ForegroundColor Red
        continue
    }
}


function CheckCFileExistence {
    [CmdletBinding()]
    param(
        
    )
    if ($CFiles.Count -eq 0){
        Write-Host "Info: No C file(s) found. Check the path again." -ForegroundColor Cyan
        return
    }
    else{
        $index = 1
        Write-Host "Found $($CFiles.Count) C File(s) as below."
        Write-Host "-------------------------------------------------" -ForegroundColor Yellow
        foreach ($cfile in $CFiles){
            $CFileWithIndex = "$index. $cfile"
            Write-Host $CFileWithIndex -ForegroundColor Yellow
            [void]$CFilesWithIndex.Add($CFileWithIndex)
            $index += 1
        }
        Write-Host "-------------------------------------------------" -ForegroundColor Yellow
    }
}

CheckCFileExistence

function CompileCToDll {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Cfile
    )
    $Cfile = $Cfile -replace "\.c", ""
    Write-Host $Cfile
    if (("$($Cfile).dll") -in $Files.Name){
        Remove-Item "$($Cfile).dll"
    }
    gcc -c "$($Cfile).c" -o "$($Cfile).o"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: DLL ompilation failed for $($Cfile).c" -ForegroundColor Red
        return
    }
    gcc -shared -o "$($Cfile).dll" "$($Cfile).o"
    Remove-Item "$($Cfile).o"
    Write-Host "Dynamic library $($Cfile).dll has been created successfully." -ForegroundColor Green
    $reply = Read-Host "Do you want to compile .dll again"
    if ($reply -eq "y"){
        $index = 1
        # $CFiles.Remove("$($Cfile).c") 已编译的C文件不再显示在列表中
        Write-Host "-------------------------------------------------" -ForegroundColor Yellow
        $CFilesWithIndex = [System.Collections.ArrayList]@()
        foreach ($cfile in $CFiles){
            $CFileWithIndex = "$index. $cfile"
            Write-Host $CFileWithIndex -ForegroundColor Yellow
            [void]$CFilesWithIndex.Add($CFileWithIndex)
            $index += 1
        }
        Write-Host "-------------------------------------------------" -ForegroundColor Yellow
        return "yes"
    }
    elseif ($reply -eq "n"){
        return "no"
    }
}

function CompileCToLib {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Cfile
    )
    $Cfile = $Cfile -replace "\.c", ""
    if (("lib$($Cfile).lib") -in $Files.Name){
        Remove-Item "lib$($Cfile).lib"
    }
    elseif (("lib$($Cfile).a") -in $Files.Name){
        Remove-Item ""lib$($Cfile).a""
    }
    gcc -c "$($Cfile).c" -o "$($Cfile).o"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: LIB compilation failed for $($Cfile).c" -ForegroundColor Red
        return
    }
    ar rcs "lib$($Cfile).a" "$($Cfile).o"
    Remove-Item "$($Cfile).o"
    Rename-Item "lib$($Cfile).a" "lib$($Cfile).lib"
    Write-Host "Static library lib$($Cfile).lib has been created successfully." -ForegroundColor Green
    $reply = Read-Host "Do you want to compile .lib again"
    if ($reply -eq "y"){
        $index = 1
        # $CFiles.Remove("$($Cfile).c") 已编译的C文件不再放进列表中
        
        Write-Host "-------------------------------------------------" -ForegroundColor Yellow
        $CFilesWithIndex = [System.Collections.ArrayList]@()
        foreach ($cfile in $CFiles){
            $CFileWithIndex = "$index. $cfile"
            Write-Host $CFileWithIndex -ForegroundColor Yellow
            [void]$CFilesWithIndex.Add($CFileWithIndex)
            $index += 1
        }
        Write-Host "-------------------------------------------------" -ForegroundColor Yellow
        return "yes"
    }
    elseif ($reply -eq "n"){
        return "no"
    }
}

while ($CFiles.Count -ne 0){
    if ($ContinueCompile -eq "no"){
        break
    }
    $reply = Read-Host "Which type of library do you want to create? (.dll or .lib for Windows)"
    if ($reply.ToLower() -eq "dll" -or $reply.ToLower() -eq ".dll"){
        $FileIndex = Read-Host "Which C library file do you want to compile?"
        if ($FileIndex -ge 1 -and $FileIndex -le $CFiles.Count){
            foreach ($CFileWithIndex in $CFilesWithIndex){
                if ($CFileWithIndex -match "^$($FileIndex). "){
                    $cfile = $CFileWithIndex -replace "$($FileIndex). ", ""
                    $cfile
                    $ContinueCompile = CompileCToDll -Cfile $cfile
                        
                }
            }
        }
    
        
    }
    elseif ($reply.ToLower() -eq "lib" -or $reply.ToLower() -eq ".lib") {
        $FileIndex = Read-Host "Which C library file do you want to compile?"
        if ($FileIndex -ge 1 -and $FileIndex -le $CFiles.Count){
            foreach ($CFileWithIndex in $CFilesWithIndex){
                if ($CFileWithIndex -match "^$($FileIndex). "){
                    $cfile = $CFileWithIndex -replace "$($FileIndex). ", ""
                    $ContinueCompile = CompileCToLib -Cfile $cfile
                    
                }
            }
        }
    }
    elseif ($reply -eq "exit") {
        break
    }
    else {
        Write-Host "Please enter correct format (.dll or .lib)" -ForegroundColor Red
    }
}

Read-host "Do you need to compile C file and link .dll or .lib to EXE"



