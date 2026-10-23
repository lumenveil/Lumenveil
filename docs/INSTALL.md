# Installing Lumenveil

## What you need

- Windows 10 or 11.
- The World of Warcraft 3.3.5a client, build 12340, in any language. Lumenveil doesn't include the game and doesn't
  say where to get it.
- A graphics card with Direct3D 9 and pixel shader 3.0 support. The effects are heavy; see
  [TROUBLESHOOTING.md](TROUBLESHOOTING.md#the-frame-rate-is-low) for what to turn down.

## Install

1. Download `Lumenveil-<version>.zip` from the project's Releases page. If your antivirus warns about it, see
   [Antivirus warnings](TROUBLESHOOTING.md#antivirus-warnings).
2. Close the game.
3. Open the zip and drag everything in it into your game folder, the one that holds `Wow.exe` and the `Data` folder.
   If Windows asks whether to replace files, a previous Lumenveil is there: say yes. Your `CoAVolFog.ini` is not
   replaced if you keep a copy, see [Updating](#updating).
4. Double-click `Lumenveil-Setup.cmd`. It reads your own game archives and writes two files next to `Wow.exe`:
   - `lampdata.bin`: where the lamps, torches, braziers, candles and lit windows of the world stand, and their colour;
   - `liquiddata.bin`: where the lakes and the sea are, for the fog that lies over water.

   This takes one to five minutes. Nothing in your game files changes, and nothing is sent anywhere.
5. Start the game the way you always do. Press **Ctrl+F12** to see the game with and without Lumenveil, and
   **Ctrl+F7** to open the settings.

Run `Lumenveil-Setup.cmd` again only after you install a game patch or a texture pack that changes the world's
models. Without `lampdata.bin` the game still runs with the fog, but placed lamps give no light; without
`liquiddata.bin` the fog takes all ground for land.

### What goes where

| File | What it is |
|---|---|
| `version.dll` | A small loader. `Wow.exe` loads a file of this name from its own folder; it loads `CoAVolFog.dll` and passes everything else on to Windows' own `version.dll` |
| `CoAVolFog.dll` | The renderer |
| `CoAVolFog.ini` | Your settings |
| `CoAVolFog-regions.ini` | The look of each tuned zone, by hour and weather |
| `Lumenveil\lamp_extract.exe` | The setup tool `Lumenveil-Setup.cmd` runs |
| `Lumenveil\*.txt` | Licences and notices |
| `Lumenveil-Setup.cmd`, `Lumenveil-Uninstall.cmd` | Setup and removal |

Files Lumenveil writes itself, next to `Wow.exe`:

| File | When |
|---|---|
| `lampdata.bin`, `liquiddata.bin` | By `Lumenveil-Setup.cmd` |
| `CoAVolFog.log` | At every start: what the mod found and did; useful when something goes wrong |
| `CoAVolFog-spots.txt`, `CoAVolFog-spots\` | When you save a spot with Ctrl+F5 |

## Updating

Close the game, keep a copy of your `CoAVolFog.ini` if you changed settings, and drag the new zip's files into the
game folder as above. Settings that are new in a release take their default when your old ini doesn't have them, so
you can put your old ini back. Run `Lumenveil-Setup.cmd` again when the release notes say so.

## Uninstall

Close the game and double-click `Lumenveil-Uninstall.cmd`. Or delete these by hand: `version.dll`, `CoAVolFog.dll`,
`CoAVolFog.ini`, `CoAVolFog-regions.ini`, `lampdata.bin`, `liquiddata.bin`, `CoAVolFog.log`, `CoAVolFog-spots.txt`,
the `CoAVolFog-spots` and `Lumenveil` folders, and the two `Lumenveil-*.cmd` files. The game is then exactly as before.

To switch Lumenveil off without removing it, set `Enable=0` in `CoAVolFog.ini`.

## With other graphics mods

- **DXVK** (Direct3D 9 on Vulkan, as `d3d9.dll` next to `Wow.exe`): works. Lumenveil sits on top of whatever
  Direct3D 9 the game loads.
- **ReShade:** works. Lumenveil's effects are drawn before ReShade's, so ReShade sees the fog. If your ReShade preset
  has its own fog or depth-of-field effects, you may want them off. [RESHADE.md](RESHADE.md) explains how to install
  ReShade with Lumenveil and includes the preset the README's screenshots were taken with.
- **Texture packs** (`patch-*.MPQ` in `Data`): work. Run `Lumenveil-Setup.cmd` after installing one, since it reads
  the models the game will use. They use more of the game's memory; see
  [TROUBLESHOOTING.md](TROUBLESHOOTING.md#the-game-closes-with-not-enough-memory-resources).
- **Other mods that use a `version.dll`**: only one file can have that name. Lumenveil can't run beside them unless
  they load each other.
- **Anti-aliasing:** Lumenveil needs the depth of every pixel, which the game's own multisampling hides, so it tells
  the game that multisampling isn't available. Use the anti-aliasing of your graphics driver's control panel, DXVK or
  ReShade (SMAA, FXAA) instead.

## Windows warnings

The setup tool and the DLLs are not signed with a paid certificate, so Windows SmartScreen may say "Windows protected
your PC" the first time: choose "More info" and "Run anyway" if you downloaded the zip from the project's Releases
page. Some antivirus programs distrust any DLL that a game loads from its own folder; you can check the files against
the checksums on the Releases page or against GitHub's signed record of the build, or build them yourself
([TROUBLESHOOTING.md](TROUBLESHOOTING.md#antivirus-warnings), [BUILDING.md](BUILDING.md)).
