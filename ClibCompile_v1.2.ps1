
<#
Further Developing

1. Let user choice different functions
2. error handling
3. Graphical Interface
4. progress bar
5. Other language support
6. Generate exe file of script
#>


$CFiles = [System.Collections.ArrayList]@()
$CFilesWithIndex = [System.Collections.ArrayList]@()
#$pattern = '^[a-zA-Z]:\\(?:[^\\/:*?"<>|\r\n]+\\)*[^\\/:*?"<>|\r\n]*$'
$Files = "empty"
$ContinueCompile = ""
$Spaces = " " * 40
$Spinner = @("⊶⊷", "⋅˖+┼╋┼+˖", "|/-\|/-\", "⠁⠂⠄⡀⡈⡐⡠⣀⣁⣂⣄⣌⣔⣤⣥⣦⣮⣶⣷⣿⡿⠿⢟⠟⡛⠛⠫⢋⠋⠍⡉⠉⠑⠡⢁", "⠀⡀⠄⠂⠁⠈⠐⠠⢀⣀⢄⢂⢁⢈⢐⢠⣠⢤⢢⢡⢨⢰⣰⢴⢲⢱⢸⣸⢼⢺⢹⣹⢽⢻⣻⢿⣿⣶⣤⣀")

$barWidth = 60

$CFilesWithIndex = [System.Collections.ArrayList]@()
# $CHOICE = @("1. Compile Library", "2. Compile EXE")

function SearchCFiles {
    param(

    )
    $index = 0
    $FileIndex = 0
    foreach ($cfile in $CFiles){
        $Waiting1 = Get-Random -Minimum 0.1 -Maximum 0.3
        $percentComplete = ($FileIndex / $CFiles.Count) * 100
        $percentComplete = "{0:F1}" -f $percentComplete
        $completedWidth = [math]::Round($barWidth * ($FileIndex / $CFiles.Count))
        # 创建进度条字符串
        $progressBar = ("#" * $completedWidth).PadRight($barWidth)

        
        $spinner1 = $Spinner[1][$index]
        $spinner2 = $Spinner[2][$index]
        # 输出进度条
        Write-Host -NoNewline "`r$spinner1 Sorting...... $spinner2  [$progressBar] $percentComplete%"
        
        if ($index -eq $Spinner[1].Length - 1){
            $index = -1
        }
                
        $index += 1
        $FileIndex += 1
        Start-Sleep $Waiting1
    }
}


function AddIndexForCFiles {
    $index = 1
    foreach ($cfile in $CFiles){
        $CFileWithIndex = "$index. $cfile"
        [void]$CFilesWithIndex.Add($CFileWithIndex)
        $index += 1
    }
}  # 可以加一个条件进去，listcfile


while ($true){
    $CFolderPath = Read-Host "Please enter your C Folder Path"
    if (Test-path $CFolderPath) {
        Set-Location $CFolderPath
        Write-Host "Set location to $($CFolderPath)" -ForegroundColor Green
        $Files =  Get-ChildItem $CFolderPath
        foreach ($file in $Files){
            if (-not ($file.PSIsContainer) -and $file.Name -match "\.c$"){
                [void]$CFiles.Add($file.Name)
            }
        }
        $index = 0
        for ($i = 1; $i -lt 10; $i++){
            Write-Host -NoNewline "`r$($Spinner[3][$index]) Searching C File(s)......" -ForegroundColor Cyan
            if ($index -eq $Spinner[3].Length - 1){
                $index = -1
            }
            $index += 1
            Start-Sleep 0.15
        }
        SearchCFiles
    break
    } else {
        Write-Host "Error: This path is invalid. Please try again." -ForegroundColor Red
        continue
    }
    
}

AddIndexForCFiles

function ListCFiles {
    Write-Host "-------------------------------------------------" -ForegroundColor Yellow
    for ($i = 0; $i -lt $CFilesWithIndex.Count; $i++){
        Write-Host $CFilesWithIndex[$i] -ForegroundColor Yellow
    }
    Write-Host "-------------------------------------------------" -ForegroundColor Yellow
}

function CheckCFileExistence {
    [CmdletBinding()]
    param(
        
    )
    if ($CFiles.Count -eq 0){
        Write-Host -NoNewline "`rInfo: No C file(s) found. Check the path again." -ForegroundColor DarkYellow
        return
    }
    else{
        
        Write-Host "`r**********Found $($CFiles.Count) C File(s) as below.**********$Spaces" -ForegroundColor Cyan
        ListCFiles
    }
}

CheckCFileExistence

function CompileCLibrary {
    param (
        [string]$Cfile,
        [string]$LibType
    )
    $Cfile = $Cfile -replace "\.c", ""
    if ($LibType -eq "dll") {
        if (("$($Cfile).dll") -in $Files.Name) {
            Remove-Item "$($Cfile).dll"
        }
    } elseif ($LibType -eq "lib") {
        if (("lib$($Cfile).lib") -in $Files.Name) {
            Remove-Item "lib$($Cfile).lib"
        }
    }

    gcc -c "$($Cfile).c" -o "$($Cfile).o"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: $LibType compilation failed for $($Cfile).c" -ForegroundColor Red
        return
    }

    if ($LibType -eq "dll") {
        gcc -shared -o "$($Cfile).dll" "$($Cfile).o"
    } elseif ($LibType -eq "lib") {
        ar rcs "lib$($Cfile).a" "$($Cfile).o"
        Rename-Item "lib$($Cfile).a" "lib$($Cfile).lib"
    }
    Remove-Item "$($Cfile).o"
    Write-Host "$LibType library $($Cfile).$LibType has been created successfully." -ForegroundColor Green

    while ($true) {
        $reply = Read-Host "Do you want to compile C library again (Default yes)"
        if ($reply -eq "y" -or [string]::IsNullOrEmpty($reply)) {
            ListCFiles
            return "yes"
        } elseif ($reply -eq "n") {
            return "no"
        } else {
            Write-Host "Please enter again." -ForegroundColor Red
            continue
        }
    }
}

while ($CFiles.Count -ne 0){
    if ($ContinueCompile -eq "no"){
        break
    } # HERE NEED TO CHANGE!!!!!

    $LibType = Read-Host "Which type of library do you want to create? (.dll or .lib for Windows)"
    if ($LibType -eq "exit") {
        break
    }
    elseif ($LibType -eq "dll" -or $LibType -eq "lib") {
        $FileIndex = Read-Host "Which C library file do you want to compile?"
        if (-not ($FileIndex -in (1..$CFiles.Count))){
            ListCFiles
            Write-Host "Error: Please enter number listed on the screen." -ForegroundColor Red
            continue
        }
        foreach ($CFileWithIndex in $CFilesWithIndex){
            if ($CFileWithIndex -match "^$($FileIndex). "){
                $cfile = $CFileWithIndex -replace "$($FileIndex). ", ""
                $cfile
                $ContinueCompile = CompileCLibrary -Cfile $cfile -LibType $LibType
                
            }
        }
    }
    else {
        Write-Host "Please enter correct format (dll or lib)" -ForegroundColor Red
        continue
    }
}   