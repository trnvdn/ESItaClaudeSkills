<#
.SYNOPSIS
    Підключає скіли цього репозиторію до Claude Code через junction'и.

.DESCRIPTION
    Типово лінкує в каталог скілів користувача (~\.claude\skills) - тоді скіли видно
    з будь-якого проєкту й розташування робочої копії ITnet2 не має значення.
    -ProjectRoot <шлях> лінкує натомість у <шлях>\.claude\skills (лише для того проєкту).

    Junction - не копія: правки у .\skills діють одразу, git бачить їх тут.

.EXAMPLE
    .\setup.ps1
.EXAMPLE
    .\setup.ps1 -ProjectRoot C:\ITnet2\ITnet2
.EXAMPLE
    .\setup.ps1 -Remove
#>
[CmdletBinding()]
param(
    # Підключити в конкретний проєкт замість каталогу користувача
    [string] $ProjectRoot,

    # Обмежити перелік скілів (типово - усі з .\skills)
    [string[]] $Name,

    # Зняти підключення
    [switch] $Remove
)

$ErrorActionPreference = 'Stop'

$source = Join-Path $PSScriptRoot 'skills'
if (-not (Test-Path $source)) { throw "Не знайдено каталог скілів: $source" }

if ($ProjectRoot) {
    if (-not (Test-Path $ProjectRoot)) { throw "Не знайдено проєкт: $ProjectRoot" }
    $target = Join-Path $ProjectRoot '.claude\skills'
} else {
    $target = Join-Path $env:USERPROFILE '.claude\skills'
}

if (-not (Test-Path $target)) {
    New-Item -ItemType Directory -Path $target -Force | Out-Null
    Write-Host "created  $target"
}

$skills = Get-ChildItem -Path $source -Directory
if ($Name) { $skills = $skills | Where-Object { $Name -contains $_.Name } }
if (-not $skills) { throw 'Нема чого підключати - перелік скілів порожній.' }

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

if (-not $Remove) {
    Write-Host ''
    Write-Host "Готово. Каталог підключення: $target"
    Write-Host 'Перезапустіть сесію Claude Code, щоб скіли зʼявились у переліку.'
}
