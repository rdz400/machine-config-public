Write-Host 'Welcome to PowerShell my friend.'

# VIM MODUS
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -ViModeIndicator Cursor

# DEFINITIES
$Env:rd_coding = "$Env:OneDrive\home\07-coding"
$Env:rd_jp = "$Env:rd_coding\jupyter-notebooks"


# FUNCTIES
function c {
    # Make it easy to switch locations
    param ([ValidateSet(
        "i", "p", "a", "r", "x", "s", "j", "appdata", "d", "dl", "v")]
           [String]$Loc)

    switch ($Loc) {
        "i" { Set-Location $Env:OneDrive\home\00-inbox }
        "p" { Set-Location $Env:OneDrive\home\01-projects }
        "a" { Set-Location $Env:OneDrive\home\02-areas }
        "r" { Set-Location $Env:OneDrive\home\03-resources }
        "x" { Set-Location $Env:OneDrive\home\05-archive }
        "s" { Set-Location $Env:SCRIPTS_FOLDER }
        "appdata" { Set-Location $Env:APPDATA }
        "dl" { Set-Location $Env:OneDrive\home\06-datalake}
        "d" { Set-Location "$Env:USERPROFILE\Downloads"}
        "j" { Set-Location $Env:rd_jp }
        "v" { Set-Location $Env:VAULT_OBSIDIAN }
        Default { Set-Location $Env:REPOS}
    }
}

function cc { code -n . }  # open current folder in vscode
function pjp { jupyter lab $Env:rd_jp }
function jp { jupyter lab . }
function st { Start-Process . }  # open current folder in explorer
function touch {
    param ([Parameter(Mandatory=$true)][String]$FileName)
    $null > $FileName
}

##################
## Prompt
###################

function stylize {
    param ([string]$Text)
    "$($PSStyle.Foreground.BrightCyan)$($PSStyle.Bold)" + $Text + "$($PSStyle.Reset)"
}

# Add entries here, this will be used by the prompt function for setting the 
# prefix. Add subdirectories before parent directories.
$_match_paths = [ordered]@{
    "ρ" = [regex]::Escape($(Resolve-Path $Env:REPOS).Path);
    "δ" = [regex]::Escape($(Resolve-Path $Env:OneDrive).Path);
    "~" = [regex]::Escape($(Resolve-Path ~).Path);
}

function prompt {
    $current_location = $($ExecutionContext.SessionState.Path.CurrentLocation).Path

    $result = $null
    foreach ($key in $_match_paths.Keys) {
        $current_path = $($_match_paths[$key])
        $result = $current_location -match "^($current_path)(.*)`$"
        if ($result) {
            $matching_key = $key
            $trailing_part = $Matches[2]
            break
        }
    }

    if ($result) {
        $prompt_path = "${matching_key}${trailing_part}"
    } else {
        $prompt_path = $current_location
    }
    $full_prompt = "PS $prompt_path$('>' * ($NestedPromptLevel + 1)) "
    stylize $full_prompt
}

# Function to get a lot of details about subfolders
function subdetails {
    
    Get-ChildItem -Directory |
        Select-Object Name,
            @{
                name='SubfolderCount'
                expr={(gci $_ -Recurse -Directory).Count}
            },
            @{
                name='FileCount'
                expr={(gci $_ -Recurse -File).Count}
            },
            @{
                name='Size'
                expr={(gci $_ -Recurse -File | measure -Property length -Sum).Sum / 1MB}
            },
            @{
                name='Extensions'
                expr={@(gci $_ -Recurse -File | Group-Object -Property Extension -NoElement).Name -join ", "}
            } |
        Sort-Object -Property Size
}
