<#
.SYNOPSIS
    Ставить junction'и на скіли цього репозиторію у каталог, де їх шукає Claude Code.
.EXAMPLE
    .\setup.ps1
    .\setup.ps1 -ProjectRoot C:\ITnet2\ITnet2
    .\setup.ps1 -Scope User
    .\setup.ps1 -Remove
#>
[CmdletBinding()]
param(
    # Куди лінкувати: Project - <ProjectRoot>\.claude\skills, User - ~\.claude\skills
    [ValidateSet('Project', 'User')]
    [string] $Scope = 'Project',

    [string] $ProjectRoot = 'D:\ITA\ITNet2',

    # Обмежити перелік скілів (типово - усі з .\skills)
    [string[]] $Name,

    [switch] $Remove
)

$ErrorActionPreference = 'Stop'

$source = Join-Path $PSScriptRoot 'skills'
$target = if ($Scope -eq 'User') {
    Join-Path $env:USERPROFILE '.claude\skills'
} else {
    Join-Path $ProjectRoot '.claude\skills'
}

if (-not (Test-Path $target)) {
    throw "Не знайдено каталог скілів: $target"
}

$skills = Get-ChildItem -Path $source -Directory
if ($Name) { $skills = $skills | Where-Object { $Name -contains $_.Name } }

foreach ($skill in $skills) {
    $link = Join-Path $target $skill.Name
    $item = Get-Item -LiteralPath $link -ErrorAction SilentlyContinue

    if ($item) {
        if ($item.LinkType -ne 'Junction') {
            Write-Warning "$link - справжній каталог, не junction. Пропущено."
            continue
        }
        # rmdir знімає сам junction і не чіпає вміст цілі (Remove-Item ходить усередину)
        cmd.exe /c rmdir "$link" | Out-Null
        if ($Remove) { Write-Host "removed  $($skill.Name)"; continue }
    } elseif ($Remove) {
        continue
    }

    New-Item -ItemType Junction -Path $link -Target $skill.FullName | Out-Null
    Write-Host "linked   $($skill.Name)  ->  $($skill.FullName)"
}
