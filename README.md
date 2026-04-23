# Endfield Uncensored

Endfield Uncensored is a small Windows loader and runtime patch for *Arknights: Endfield* that removes the transparency-based censorship filter.

![Version](https://img.shields.io/badge/version-5.0.0.1-orange)
![Build](https://img.shields.io/badge/preview-orange)
![License](https://img.shields.io/badge/license-AGPL--3.0-green)

The bundled font files are not covered by the project license. They remain under their own licenses shipped alongside them in [Inter OFL](https://github.com/DynamiByte/Endfield-Uncensored/blob/master/fonts/Inter/OFL.txt), [JetBrains Mono OFL](https://github.com/DynamiByte/Endfield-Uncensored/blob/master/fonts/JetBrainsMono/OFL.txt), and [DejaVuSansMono LICENSE](https://github.com/DynamiByte/Endfield-Uncensored/blob/master/fonts/DejaVuSansMono/LICENSE).

---

## Highlights

- Single-binary release: `EFU.exe` embeds the mod (a `.dll` file), extracting only when it needs to inject
- Full custom Zig GUI stack with an OpenGL renderer, embedded font subsets, and no external GUI framework
- Interactive CLI mode and silent one-shot mode
- Launch support for the normal game path and DX11 mode
- Optional EFMI / XXMI launcher handoff from CLI
- Automatic game path detection from `Player.log` (GRYPHLINK log) and common install paths
- Can inject after launching from EFU or after you start the game elsewhere
- Post-launch behavior toggle to minimize or stay open, then return to ready state after the game closes

---

## Disclaimer

**THIS SOFTWARE IS NOT AFFILIATED WITH, ENDORSED BY, OR SPONSORED BY HYPERGRYPH, GRYPHLINE, OR ANY OTHER ENTITY ASSOCIATED WITH ARKNIGHTS: ENDFIELD**

- This is an independent community tool for research and educational use
- I do not own *Arknights: Endfield* or any of its assets
- This modifies the game at runtime and may violate the game's Terms of Service
- Use it at your own risk

This carries the same general risk profile as other runtime modding tools such as 3DMigoto based loaders.

If your antivirus flags the build, report it in Github issues. I try to avoid flagging. For Windows Defender / Windows Security, choose `Allow on device` if you trust the release you downloaded.

---

## Quick Start

(Note that this does not all apply to the latest release as of now)

1. Download the latest release from the [Releases](https://github.com/DynamiByte/Endfield-Uncensored/releases) page
2. Run `EFU.exe` as Administrator
3. If EFU finds the game path, press `Launch Game`
4. If EFU does not find the path, or you prefer not to launch from the app, start the game normally and EFU will inject when `Endfield.exe` appears
5. Use the lower toggle to choose `Minimize on Launch` or `Stay open on Launch`

If you keep EFU open, it returns to a ready state after the game closes so you can use it again without reopening it.

### GUI Notes

- The launch button is only enabled when EFU knows the game path and the game is not already running
- Triple right click the `Launch Game` button to use the alternate launch mode for that launch
- Starting EFU with `-DX11` makes the normal launch path use `-force-d3d11`
- If EFU is left waiting, it can still inject when the game is launched externally

---

## CLI

`EFU.exe -cli` starts the interactive console loader. It can wait for the game, launch it for you, or inject after an external start.

### Common arguments

Arguments are case-insensitive. Prefixes `-`, `--`, and `/` are accepted. Boolean values are also case-insensitive; use `true|false` in examples, but `on|off`, `yes|no`, `y|n`, and `t|f` also work.

- `-c` / `-cli`: interactive console mode
- `-s` / `-silent`: one-shot launch and inject flow with error popups instead of an interactive console
- `-DX11`: launch the game with `-force-d3d11`
- `--gp` / `--game-path [PATH_TO_Endfield.exe]`: use the provided game executable instead of auto-detection for the normal game launch path
- `-y` / `-yes`: auto-confirm prompts used by the EFMI CLI flow
- `--EFMI [PATH_TO_XXMI Launcher.exe]`: launch EFMI through XXMI, with optional explicit launcher path
- `--wm` / `--fwm` / `--force-wine-mode true|false`: GUI-only override for Wine detection
- `--am` / `--allow-minimize true|false`: GUI-only override for minimize behavior

### EFMI / XXMI integration

`EFMI` switches EFU into the CLI path and starts XXMI with `--nogui --xxmi EFMI` before injecting.

If no path is supplied, EFU looks for:

`%APPDATA%\XXMI Launcher\Resources\Bin\XXMI Launcher.exe`

`DX11` and `EFMI` are mutually exclusive.
`game-path` and `EFMI` are also mutually exclusive for the same reason.
EFMI handles that itself.

### Silent mode

`-silent` is intended for one-shot use. It requires EFU to successfully detect the normal game path or the EFMI launcher path.

---

## Building

To build from source you currently need:

- Zig [`0.16.0`](https://ziglang.org/download/0.16.0/zig-x86_64-windows-0.16.0.zip)

Build with:

```bash
zig build -Doptimize=ReleaseSmall
```

The generated artifact is:

```bash
./zig-out/bin/EFU.exe
```

The default build packages the patch DLL into the executable instead of generating a separate DLL beside it.

---

## Links

- Releases: [GitHub Releases](https://github.com/DynamiByte/Endfield-Uncensored/releases)
- GameBanana: [Endfield Uncensored](https://gamebanana.com/mods/651108)
- Issues: [GitHub Issues](https://github.com/DynamiByte/Endfield-Uncensored/issues)
- Discord: ["dynamicbyte"](https://discord.com/users/1077491551267213392)
