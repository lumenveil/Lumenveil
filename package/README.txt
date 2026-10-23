Lumenveil - volumetric fog, night lights, light shafts and water for the World of Warcraft 3.3.5a client

INSTALL
  1. Close the game.
  2. Copy everything from the zip into your game folder, next to Wow.exe.
  3. Double-click Lumenveil-Setup.cmd once. It reads your own game files and writes where the world's lamps and
     water are (lampdata.bin, liquiddata.bin). One to five minutes; nothing is changed or sent anywhere.
  4. Start the game as usual.

KEYS
  Ctrl+F12  switches Lumenveil off and on, to compare with the plain game
  Ctrl+F7   opens the settings window
  Ctrl+F3   opens the region panel (the look of each zone)

UNINSTALL
  Close the game and double-click Lumenveil-Uninstall.cmd.

WHEN SOMETHING GOES WRONG
  Look in CoAVolFog.log next to Wow.exe. The full documentation, the source code and the issue tracker are on the
  project's page; see the link on the page you downloaded this from.

ANTIVIRUS
  Some antivirus programs warn about new DLLs that a game loads from its own folder, as it loads version.dll. To
  check the files, compare them with SHA256SUMS.txt on the release page, or run
  "gh attestation verify <file> --repo lumenveil/Lumenveil" with the GitHub CLI: it shows that GitHub built the file
  from the project's source. Report a false positive to your antivirus vendor; don't turn your antivirus off.

LEGAL
  Lumenveil is free, non-commercial software under the GNU General Public License v2 (LICENSE.txt). It contains no
  game files and no part of the game's code, changes none of your game files, sends nothing over the network and
  plays nothing for you. Any change to the game client may be against the terms of the service you play on, and
  anti-cheat software may detect it: read those terms first. You use Lumenveil at your own risk, with no warranty.
  Lumenveil is not affiliated with or endorsed by Blizzard Entertainment. World of Warcraft is a trademark or
  registered trademark of Blizzard Entertainment, Inc. More in LEGAL.txt.
