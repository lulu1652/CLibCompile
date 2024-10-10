# This script is used for compiling C libraries only, don't compile other C file!

<#
Further Developing

1. Let user choice different functions
2. error handling
3. Graphical Mode
4. progress bar(checked)
5. Other language support
6. Generate exe file of other C files (No libraries)
#>


$CFiles = [System.Collections.ArrayList]@()
$CFilesWithIndex = [System.Collections.ArrayList]@()
#$pattern = '^[a-zA-Z]:\\(?:[^\\/:*?"<>|\r\n]+\\)*[^\\/:*?"<>|\r\n]*$'
$Files = "empty"
$ContinueCompile = ""
$Spaces = " " * 50
$Spinner = @("⊶⊷", "⋅˖+┼╋┼+˖", "|/-\|/-\", "⠁⠂⠄⡀⡈⡐⡠⣀⣁⣂⣄⣌⣔⣤⣥⣦⣮⣶⣷⣿⡿⠿⢟⠟⡛⠛⠫⢋⠋⠍⡉⠉⠑⠡⢁", "⠀⡀⠄⠂⠁⠈⠐⠠⢀⣀⢄⢂⢁⢈⢐⢠⣠⢤⢢⢡⢨⢰⣰⢴⢲⢱⢸⣸⢼⢺⢹⣹⢽⢻⣻⢿⣿⣶⣤⣀")
$CFolderPath = ""
$barWidth = 50
$esc = [char]27
$CFilesWithIndex = [System.Collections.ArrayList]@()
# $CHOICE = @("1. Compile Library", "2. Compile EXE")
$check = "$esc[32m🗸$esc[0m"
$wrong = "$esc[31m✘$esc[0m"

function SearchCFiles {
    param(

    )
    $index = 0
    $FileIndex = 0
    foreach ($cfile in $CFiles){
        $Waiting1 = Get-Random -Minimum 0.1 -Maximum 0.3
        $percentComplete = (($FileIndex + 1) / $CFiles.Count) * 100
        $percentComplete = "{0:F1}" -f $percentComplete
        $completedWidth = [math]::Round($barWidth * (($FileIndex + 1) / $CFiles.Count))
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
    Write-Host "Please enter your C Folder Path (Enter 'exit' to quit)"
    $CFolderPath = Read-Host
    if ($CFolderPath -eq "exit"){
        break
    }
    if (Test-path $CFolderPath) {
        Set-Location $CFolderPath
        Write-Host "$check Set location to $($CFolderPath)"
        $Files =  Get-ChildItem $CFolderPath
        foreach ($file in $Files){
            if (-not ($file.PSIsContainer) -and $file.Name -match "\.c$"){
                [void]$CFiles.Add($file.Name)
            }
        }
        $index = 0
        for ($i = 1; $i -lt 10; $i++){
            Write-Host -NoNewline "`r$($Spinner[3][$index]) Searching C File(s)......"
            if ($index -eq $Spinner[3].Length - 1){
                $index = -1
            }
            $index += 1
            Start-Sleep 0.15
        }
        SearchCFiles
        break
    }
    else {
        Write-Host "$wrong $esc[31mError:$esc[0m This path is invalid. Please try again."
        continue
    }
}

AddIndexForCFiles

function ListCFiles {
    Write-Host "$esc[43m                                               $esc[0m"
    for ($i = 0; $i -lt $CFilesWithIndex.Count; $i++){
        Write-Host $CFilesWithIndex[$i] -ForegroundColor Yellow
    }
    Write-Host "$esc[43m                                               $esc[0m`n"
}

function CheckCFileExistence {
    [CmdletBinding()]
    param(
        
    )
    if ($CFiles.Count -eq 0){
        Write-Host -NoNewline "`r$esc[33mINFO:$esc[0m No C file(s) found. Check the path again."
        return
    }
    else{
        
        Write-Host "`r$check Found $($CFiles.Count) C File(s) as below.$Spaces`n"
        ListCFiles
    }
}
if ($CFolderPath -ne "exit"){
    CheckCFileExistence
}


# 省略前面部分的代码

function CompileCLibrary {
    param (
        [string]$Cfile,
        [string]$LibType
    )
    
    # 编译逻辑和删除旧文件
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

    # 编译.c文件为.o
    gcc -c "$($Cfile).c" -o "$($Cfile).o"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "$wrong $esc[31mError:$esc[0m $LibType compilation failed for $($Cfile).c"
        return
    }

    # 生成.dll或.lib文件
    if ($LibType -eq "dll") {
        gcc -shared -o "$($Cfile).dll" "$($Cfile).o"
    } elseif ($LibType -eq "lib") {
        ar rcs "lib$($Cfile).a" "$($Cfile).o"
        Rename-Item "lib$($Cfile).a" "lib$($Cfile).lib"
    }
    Remove-Item "$($Cfile).o"
    Write-Host "$check$LibType library $($Cfile).$LibType has been created successfully."
}

# 新增的检查输入序列号是否有效的函数
function ValidateFileIndices {
    param (
        [string[]]$FileIndices
    )
    $InvalidIndices = [System.Collections.ArrayList]@()
    
    foreach ($FileIndex in $FileIndices) {
        if (-not ($FileIndex -in (1..$CFiles.Count))) {
            [void]$InvalidIndices.Add($FileIndex)
        }
    }
    
    return $InvalidIndices
}

while ($CFiles.Count -ne 0){
    if ($ContinueCompile -eq "no"){
        break
    }
    
    Write-Host "Which type of library do you want to create? (.dll or .lib for Windows, Enter 'exit' to quit)"
    $LibType = Read-Host
    if ($LibType -eq "exit") {
        break
    }
    elseif ($LibType -eq "dll" -or $LibType -eq "lib") {
        Write-Host "Which C libraries file do you want to compile? (Use file numbers separated by commas, like 1,2,3)"
        $FileIndex = Read-Host
        if ($FileIndex -match "\b[1-9]\d*(?:,[1-9]\d*)*\b") {
            $FileIndices = $FileIndex.Split(",")

            # 验证文件序号是否都有效
            $InvalidIndices = ValidateFileIndices -FileIndices $FileIndices
            if ($InvalidIndices.Count -gt 0) {
                Write-Host "$wrong The following file indices are invalid: $esc[31m$($InvalidIndices -join ', ')$esc[0m"
                Write-Host "Please enter valid file indices and try again."
                continue
            }

            # 如果所有序号都有效，开始编译所有文件
            foreach ($FileIndex in $FileIndices) {
                foreach ($CFileWithIndex in $CFilesWithIndex) {
                    if ($CFileWithIndex -match "^$($FileIndex). ") {
                        $cfile = $CFileWithIndex -replace "$($FileIndex). ", ""
                        CompileCLibrary -Cfile $cfile -LibType $LibType
                    }
                }
            }

            # 编译所有文件后才询问是否继续编译
            while ($true) {
                $reply = Read-Host "Do you want to compile C library again (Default yes)"
                if ($reply -eq "y" -or [string]::IsNullOrEmpty($reply)) {
                    ListCFiles
                    break
                } elseif ($reply -eq "n") {
                    $ContinueCompile = "no"
                    break
                } else {
                    Write-Host "$wrong Please enter again."
                    continue
                }
            }

        } else {
            Write-Host "$wrong $esc[31mError:$esc[0m Please files listed on the screen (e.g., 1,2,3)"
            continue
        }
    }
    else {
        Write-Host "$wrong $esc[31mError:$esc[0m Please enter correct format (dll or lib)"
        continue
    }
}
