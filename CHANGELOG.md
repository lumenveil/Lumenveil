# Changelog

## 0.1.1 (2026-10-23)

For antivirus programs that warned about 0.1.0 (Microsoft Defender: `Trojan:Win32/Tecabans.STV!cl`, a false
positive). Nothing changes in the game.

- `version.dll`, `CoAVolFog.dll` and `lamp_extract.exe` carry version information: product, description, version,
  licence and this project's address.
- The settings window copies and pastes within itself instead of through the Windows clipboard, so the DLL no longer
  uses the clipboard functions.
- Releases are built by GitHub Actions from the tagged source, and GitHub signs a record of each build:
  `gh attestation verify` shows which source and workflow a file came from. See
  [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#antivirus-warnings).

## 0.1.0 (2026-10-21)

The first public release.

- Volumetric fog in layers and banks that lie on the ground, pool in valleys and over water, and drift with the wind;
  dust in dry zones and a humid haze in green ones; morning mist and evening haze.
- Sun and moon light shafts, also from a light outside the picture, with a memory of what the camera has seen.
- Lamps, torches, braziers, candles and lit windows light the world around them at night, with shadows, and glow in
  the fog; distant towns show their lights; darker nights.
- Light from spells, enchants and glowing projectiles; a belt lantern.
- Water with wind-driven waves, lasting reflections, sun glitter, rain rings, ripples and reflected lamps.
- Wet stone and soil, and puddles, in rain (off in the shipped settings).
- Relief on building walls, floors and models, from height maps made in the game (off in the shipped settings).
- A look for each of 37 zones, by hour and weather; a region panel to tune any zone.
- A longer view distance on the old continents.
- Ctrl+F12 switches the whole mod off and on, for comparisons; Ctrl+F7 opens the settings.
- `Lumenveil-Setup.cmd` makes the lamp and water data from the player's own game files.
