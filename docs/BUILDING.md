# Building Lumenveil

Lumenveil builds on Windows with Visual Studio's C++ tools. Everything it needs is in this repository; nothing is
downloaded while it builds.

## What you need

- Visual Studio 2022 or its Build Tools, with "Desktop development with C++" (MSVC x86 and x64).
- The Windows 10 or 11 SDK (for `fxc.exe`, the HLSL compiler).
- CMake 3.20 or later.
- PowerShell 5.1 (part of Windows) for the release script.
- Optional, for the comment check: Python 3.

The client is 32-bit, so both the DLLs and the setup tool are built for Win32.

## Build a release zip

```powershell
.\scripts\Build-Release.ps1
```

It configures and builds `engine` (the DLLs and the test harness) and `engine/tools/lamp_extract` (the setup tool) in
Release, runs the test harness unless you pass `-SkipTests` (`-CpuTestsOnly` runs the checks that need no GPU), and
writes `dist\Lumenveil-<version>.zip` with `SHA256SUMS.txt` beside it. The version comes from the top entry of
`CHANGELOG.md`, or `-Version 1.2.3`.

## Build by hand

```powershell
cmake -S engine -B build\engine -A Win32 -DFETCHCONTENT_SOURCE_DIR_IMGUI="$PWD/third_party/imgui" "-DVF_VERSION=0.1.1"
cmake --build build\engine --config Release
ctest --test-dir build\engine -C Release --output-on-failure

cmake -S engine\tools\lamp_extract -B build\lamp_extract -A Win32 -DLAMP_EXTRACT_DEPS="$PWD/third_party" "-DVF_VERSION=0.1.1"
cmake --build build\lamp_extract --config Release
```

The DLLs are `build\engine\Release\version.dll` and `CoAVolFog.dll`; the setup tool is
`build\lamp_extract\Release\lamp_extract.exe`.

- `FETCHCONTENT_SOURCE_DIR_IMGUI` points the engine at the Dear ImGui sources in `third_party/imgui`. Without it,
  CMake downloads the same version from Dear ImGui's releases and checks it by hash.
- `LAMP_EXTRACT_DEPS` is the folder holding the `libmpq`, `zlib` and `bzip2` sources.
- `VF_VERSION` is the version written into each file's version information. In PowerShell, quote the whole argument:
  unquoted, `-DVF_VERSION=0.1.1` reaches CMake split at the first dot.

## The test harness

`vfog_harness.exe` loads the real `CoAVolFog.dll`, creates a Direct3D 9 device on a hidden window, renders test scenes
through the mod and checks the pictures, the settings parser, the input handling and the CPU-side models: about 1,200
checks. It needs a GPU and an unlocked desktop session (a locked session can't create a Direct3D device). Some checks
read the keyboard state, so don't type while it runs. `--cpu-only` runs only the checks that need no GPU.

Checks that need data files made from the game (`fogdata.bin`, the zone list) are skipped when those files aren't
there, and the harness says how many were skipped. The project doesn't distribute those files.

To run it on DXVK, copy DXVK's 32-bit `d3d9.dll` next to `vfog_harness.exe`.

## Build options

| Option | Default | What it does |
|---|---|---|
| `FXC` | newest in the Windows SDK | Path of `fxc.exe` |
| `FETCHCONTENT_SOURCE_DIR_IMGUI` | (download) | Folder of the Dear ImGui sources; the release script sets `third_party/imgui` |
| `VF_VERSION` | `0.0.0` | Version (major.minor.patch) written into the version information of `version.dll`, `CoAVolFog.dll` and `lamp_extract.exe`; the release script sets it |
| `VF_SYSTEM_CLIPBOARD` | `OFF` | Lets the settings window copy and paste through the Windows clipboard. Off, it copies and pastes within itself and the DLL doesn't use the clipboard functions; the harness checks which |

## Releases

A tag `v<version>` runs [.github/workflows/release.yml](../.github/workflows/release.yml) on GitHub's servers: it
checks that the tag matches the top entry of `CHANGELOG.md`, runs `Build-Release.ps1 -CpuTestsOnly` and the comment
check, has GitHub sign a provenance record of the zip and of each program in it, and publishes the release with
`SHA256SUMS.txt`. `gh attestation verify <file> --repo lumenveil/Lumenveil` checks a file against that record.

## Code rules

- No comments in the C++, HLSL and CMake files (`engine/tools/check_comments.py` checks it); names say what the code
  does, and the design is described in the documentation.
- Every change of behaviour gets a check in the harness, and the check must fail when the change is undone.
- Harness checks show that the code does what it should in the test scenes; say so when a change hasn't been seen in
  the game.
- Code that reads, calls or changes the running client recognises it by a hash of its bytes
  (`engine/src/client_code.h`), never by a copy of them.

See [CONTRIBUTING.md](../CONTRIBUTING.md) and [LEGAL.md](../LEGAL.md).
