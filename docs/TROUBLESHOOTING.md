# Troubleshooting

Most answers are in `CoAVolFog.log`, next to `Wow.exe`. It is written at every start: what the mod found in the
client, which hooks it installed, which data files it read, and a summary every 60 seconds. When you open an issue,
attach the log (remove your Windows user name from the paths if you like), and say what you see.

## Antivirus warnings

Some antivirus programs warn about Lumenveil's download; Microsoft Defender has called it
`Trojan:Win32/Tecabans.STV!cl`. Detections like this judge a new file by its shape when nobody has reported on it yet.
Lumenveil's `version.dll` is a DLL that `Wow.exe` loads from its own folder, as many graphics mods load (ReShade among
them), and some malware loads that way too. Lumenveil's files are not code-signed, so nothing vouches for their
publisher.

Since 0.1.1, each file carries version information (product, description, version, licence, this project's address),
the settings window no longer uses the Windows clipboard, and each release is built by GitHub Actions from the tagged
source ([release.yml](../.github/workflows/release.yml)), with a record of the build that GitHub signs.

To check a file you downloaded:

- Compare its SHA-256 with `SHA256SUMS.txt` on the release page. In PowerShell: `Get-FileHash Lumenveil-0.1.1.zip`.
- With the [GitHub CLI](https://cli.github.com/):
  `gh attestation verify Lumenveil-0.1.1.zip --repo lumenveil/Lumenveil`. It shows that GitHub built the file from
  this repository's source at that release's tag. It works for `version.dll`, `CoAVolFog.dll` and
  `Lumenveil\lamp_extract.exe` from the zip too.
- Or build Lumenveil yourself from the source: [BUILDING.md](BUILDING.md).

If your antivirus still flags it, report the file to your antivirus vendor as a false positive (for Microsoft
Defender: [submit a file for malware analysis](https://www.microsoft.com/en-us/wdsi/filesubmission)). If you are unsure,
don't use the file. Don't turn your antivirus off for Lumenveil.

## Nothing changes in the game

- **There is no `CoAVolFog.log`:** the game didn't load Lumenveil. Check that `version.dll` and `CoAVolFog.dll` are in
  the same folder as the `Wow.exe` you start. A launcher may start another copy of the game.
- **The log says "hooks not installed" or "differs from the 12340 client":** your `Wow.exe` isn't the 3.3.5a build
  12340, or something else changed it. Lumenveil stays off rather than patch the wrong place.
- **The log says "Direct3DCreate9Ex requested":** the game runs on its Direct3D 9Ex path. Set `SET gxApi "d3d9"` in
  `WTF\Config.wtf`, or remove the `gxApi` line.
- **The log says "shader creation failed; fog disabled for this device":** your graphics card or driver refused the
  mod's shaders. Update the driver; with an old card, try DXVK.
- **Ctrl+F12 was pressed:** the plain game is shown until you press it again. The settings window (Ctrl+F7) says so on
  its top line.

## A key does nothing

- The keys work only with `Overlay=1` in `CoAVolFog.ini` (read at start).
- On laptops whose F-keys send media keys, hold Fn. The log names the first shortcuts that reach the game, for
  example `overlay: Ctrl+Media Previous pressed (OverlayKey is Ctrl+F7)`, so you can see what arrived instead.
- Another program may take the key first (screen recorders, ReShade, overlays). Choose another key in
  `CoAVolFog.ini`, see [SETTINGS.md](SETTINGS.md#keys).

## The game closes with "Not enough memory resources"

The 3.3.5a client is a 32-bit program with 2 GB of memory, and a longer view distance keeps more of the world loaded.
In order of how much they free:

1. `FarClipMax=0` in the settings window or `CoAVolFog.ini`: the game's own view distance limit on the old
   continents (the lifted limit holds about four times as much terrain).
2. A shorter view distance in the game's video options.
3. Fewer or smaller texture packs, if you use any.
4. `Relief=0` and `ReliefModels=0`.

## The frame rate is low

Lumenveil does a lot of work for every pixel. In order of how much they usually give back:

1. `Quality=1` in the settings window.
2. Fewer lamps: `LampCount` 32 or lower, `LampShadows` 0.
3. `Relief=0` (or Ctrl+F4).
4. `EffectLight=0`, `WaterMemory=0`, `ShaftMemory=0`.
5. A shorter view distance in the game's video options.

`PerfLog=1` in `CoAVolFog.ini` writes three "perf:" lines a minute to the log with the time each pass takes; attach
them to an issue about speed.

If the frame rate is low while your graphics card is far from busy, look in `WTF\Config.wtf` for `gxFixLag`: at 1 the
game waits for the graphics card at the end of every frame. `SET gxFixLag "0"` lets the card work on one frame while
the game prepares the next.

## Lamps give no light at night

- Run `Lumenveil-Setup.cmd` once. The log then says "lamp data: N maps, N lamps, N windows"; without it, "no lamp
  data".
- By day, lamps keep only `LampDayLight` of their light.
- `LampLight` and `LampFog` at 0 turn them off.

## Nights are too dark, or the world is too foggy

- `NightDarkness` sets how much darker nights are than in the plain game; 0 gives the game's own nights.
- `Density` is the amount of fog everywhere; the settings window's "This zone" slider changes it for the zone you're
  in only.
- A tuned zone may set its own values for the hour and weather. The settings window's top line says when zone
  settings apply; the region panel (Ctrl+F3) shows and edits them.

## Everything looks blurry or jagged

Lumenveil turns off the game's own multisampling (it needs each pixel's depth). Use your driver's, DXVK's or
ReShade's anti-aliasing instead ([INSTALL.md](INSTALL.md#with-other-graphics-mods)).

## Lumenveil-Setup.cmd fails

The details are in `Lumenveil\setup-lamps.log` and `Lumenveil\setup-water.log`. Lumenveil-Setup.cmd must be in the
game folder, next to `Wow.exe` and `Data`, and the game's archives must not be open in another program.

## A warning from the service you play on

Lumenveil sends nothing over the network, but anti-cheat software can look at the game's memory. If you get a
warning, stop using Lumenveil there; see "Before you play online" in the [README](../README.md). Lumenveil has no
way to hide from such checks and won't get one.
