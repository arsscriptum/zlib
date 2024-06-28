#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   setup_env.ps1                                                                ║
#║   script that will set the zlib environment value                              ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <guillaume.plante@luminator.com>                            ║
#║   Copyright (C) Luminator Technology Group.  All rights reserved.              ║
#╚════════════════════════════════════════════════════════════════════════════════╝

function Get-ZLibPath{
    [CmdletBinding(SupportsShouldProcess)]
    param()    

    if(-not([string]::IsNullOrEmpty("$PSScriptRoot"))){
        $ZlibPath = (Resolve-Path "$PSScriptRoot").Path
        $ReadMePath = Join-Path "$ZlibPath" "README.md"
        $PathOk = (Get-Content "$ReadMePath" | Select -First 1) -eq '# zlib'

        if($PathOk){
            return "$ZlibPath"
        }
    }

    if(-not([string]::IsNullOrEmpty($ENV:DevelopmentDirectory))){
        $ZlibPath = Join-Path "$ENV:DevelopmentDirectory" "zlib"
        if(Test-Path -Path "$ZlibPath" -PathType Container){
            return "$ZlibPath"
        }
    }
    return $Null
}


if([string]::IsNullOrEmpty("$ENV:ZLIB_PATH")){
    $ZlibPath = Get-ZLibPath
    Write-Host "zlib library path `"$ZlibPath`""
    Set-EnvironmentVariable -Name "ZLIB_PATH" -Value "$ZlibPath" -Scope User
    Set-EnvironmentVariable -Name "ZLIB_PATH" -Value "$ZlibPath" -Scope Session
}

