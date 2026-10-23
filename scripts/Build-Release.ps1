#Requires -Version 5.1
<#
.SYNOPSIS
  Builds Lumenveil and packs the release zip.

.DESCRIPTION
  Configures and builds engine\ (CoAVolFog.dll, version.dll, the test harness) and engine\tools\lamp_extract (the
  setup tool) for Win32 in Release, with the version written into each file's version information, runs the test
  harness, and writes dist\Lumenveil-<version>.zip with dist\SHA256SUMS.txt. See docs\BUILDING.md.

.PARAMETER Version
  The version (major.minor.patch) in the zip's name and in each file's version information. Default: the first
  "## x.y.z" heading of CHANGELOG.md.
.PARAMETER SkipTests
  Don't run the test harness.
.PARAMETER CpuTestsOnly
  Run only the checks that need no GPU (for build machines without one).
#>
param(
  [string]$Version = '',
  [switch]$SkipTests,
  [switch]$CpuTestsOnly
)
$ErrorActionPreference = 'Stop'
$Root = Split-Path $PSScriptRoot -Parent
$Build = Join-Path $Root 'build'
$Dist = Join-Path $Root 'dist'

function Find-CMake {
  $c = Get-Command cmake.exe -ErrorAction SilentlyContinue
  if ($c) { return $c.Source }
  $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
  if (Test-Path $vswhere) {
    $vs = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    $p = Join-Path "$vs" 'Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'
    if ($vs -and (Test-Path $p)) { return $p }
  }
  throw 'CMake not found: install CMake 3.20 or later, or Visual Studio with its CMake component.'
}

function Invoke-Step([string]$Exe, [string[]]$Arguments) {
  & $Exe @Arguments
  if ($LASTEXITCODE) { throw "$([IO.Path]::GetFileName($Exe)) failed (exit $LASTEXITCODE)" }
}

if (-not $Version) {
  $m = Select-String -Path (Join-Path $Root 'CHANGELOG.md') -Pattern '^##\s+(\d+\.\d+\.\d+)' | Select-Object -First 1
  if (-not $m) { throw 'No version heading in CHANGELOG.md; pass -Version.' }
  $Version = $m.Matches[0].Groups[1].Value
}
$cmake = Find-CMake
$ctest = Join-Path (Split-Path $cmake) 'ctest.exe'
$engineBuild = Join-Path $Build 'engine'
$toolBuild = Join-Path $Build 'lamp_extract'

Write-Host "== Lumenveil $Version"
# Dear ImGui is built from third_party\imgui (the copy this release ships), never downloaded
if (-not (Test-Path (Join-Path $Root 'third_party\imgui\imgui.h'))) { throw 'third_party\imgui is missing.' }
$imgui = (Join-Path $Root 'third_party\imgui').Replace('\', '/')
$deps = (Join-Path $Root 'third_party').Replace('\', '/')
Invoke-Step $cmake @('-S', (Join-Path $Root 'engine'), '-B', $engineBuild, '-A', 'Win32', "-DFETCHCONTENT_SOURCE_DIR_IMGUI=$imgui",
                     "-DVF_VERSION=$Version")
Invoke-Step $cmake @('--build', $engineBuild, '--config', 'Release', '--parallel')
Invoke-Step $cmake @('-S', (Join-Path $Root 'engine\tools\lamp_extract'), '-B', $toolBuild, '-A', 'Win32',
                     "-DLAMP_EXTRACT_DEPS=$deps", "-DVF_VERSION=$Version")
Invoke-Step $cmake @('--build', $toolBuild, '--config', 'Release', '--parallel', '--target', 'lamp_extract')

$bin = Join-Path $engineBuild 'Release'

if ($CpuTestsOnly) {
  Push-Location $bin
  try {
    Invoke-Step (Join-Path $bin 'vfog_harness.exe') @('--cpu-only', '--out', (Join-Path $engineBuild 'harness-out'),
                 '--data', (Join-Path $Root 'engine\data\fogdata.bin'), '--ini', (Join-Path $Root 'engine\CoAVolFog.ini'))
  } finally { Pop-Location }
} elseif (-not $SkipTests) {
  Invoke-Step $ctest @('--test-dir', $engineBuild, '-C', 'Release', '--output-on-failure')
}

$name = "Lumenveil-$Version"
$stage = Join-Path $Dist $name
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force (Join-Path $stage 'Lumenveil\licenses') | Out-Null
Copy-Item (Join-Path $bin 'version.dll'), (Join-Path $bin 'CoAVolFog.dll') $stage
Copy-Item (Join-Path $Root 'package\*') $stage -Exclude 'README.txt'
Copy-Item (Join-Path $toolBuild 'Release\lamp_extract.exe') (Join-Path $stage 'Lumenveil')
Copy-Item (Join-Path $Root 'package\README.txt') (Join-Path $stage 'Lumenveil\README.txt')
Copy-Item (Join-Path $Root 'LICENSE') (Join-Path $stage 'Lumenveil\LICENSE.txt')
Copy-Item (Join-Path $Root 'THIRD-PARTY-NOTICES.md') (Join-Path $stage 'Lumenveil\THIRD-PARTY-NOTICES.txt')
Copy-Item (Join-Path $Root 'LEGAL.md') (Join-Path $stage 'Lumenveil\LEGAL.txt')
Copy-Item (Join-Path $Root 'third_party\licenses\*') (Join-Path $stage 'Lumenveil\licenses')

$zip = Join-Path $Dist "$name.zip"
if (Test-Path $zip) { Remove-Item $zip }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory($stage, $zip, [IO.Compression.CompressionLevel]::Optimal, $false)
$sums = Get-ChildItem $stage -Recurse -File | Sort-Object FullName | ForEach-Object {
  '{0}  {1}' -f (Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant(), $_.FullName.Substring($stage.Length + 1).Replace('\', '/')
}
$sums += '{0}  {1}' -f (Get-FileHash $zip -Algorithm SHA256).Hash.ToLowerInvariant(), "$name.zip"
[IO.File]::WriteAllLines((Join-Path $Dist 'SHA256SUMS.txt'), $sums)
Write-Host "== $zip"
Get-Content (Join-Path $Dist 'SHA256SUMS.txt') | Write-Host
