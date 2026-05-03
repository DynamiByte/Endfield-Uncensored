# Endfield Uncensored

Endfield Uncensored is a standalone Windows loader and runtime patch for *Arknights: Endfield* that removes the transparency-based censorship filter.

![Version](https://img.shields.io/badge/version-5.0.0.3-orange)
![License](https://img.shields.io/badge/license-AGPL--3.0-green)

## Highlights

- Single-binary release: `EFU.exe` embeds the patch DLL and extracts it only when needed for injection
- Full custom Zig GUI stack with an OpenGL renderer, embedded font subsets, and no external GUI framework
- Scrollable GUI output log with mouse-wheel scrolling, scrollbar dragging, text selection, `Ctrl+A`, and `Ctrl+C`
- Interactive CLI mode and silent one-shot mode
- Launch support for the normal game path, DX11 mode, and optional EFMI / XXMI handoff
- GUI EFMI support when EFMI / XXMI is detected, with an attached EFMI launch toggle
- Alt+F12 runtime toggle for the replacement dither patch, limited to the active game window
- Automatic game path detection from `Player.log` / GRYPHLINK data and common install paths
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

If your antivirus flags the build, report it in GitHub issues. I try to avoid flagging. For Windows Defender / Windows Security, choose `Allow on device` if you trust the release you downloaded.

---

## Quick Start

1. Download the latest `EFU.exe` from the [Releases](https://github.com/DynamiByte/Endfield-Uncensored/releases) page
2. Run `EFU.exe` as Administrator
3. If EFU finds the game path, press `Launch Game`
4. If EFU does not find the path, or you prefer not to launch from the app, start the game normally and EFU will inject when `Endfield.exe` appears
5. Use the lower toggle to choose `Minimize on Launch` or `Stay open on Launch`

If you keep EFU open, it returns to a ready state after the game closes so you can use it again without reopening it.

### GUI Notes

- The launch button is only enabled when EFU knows the game path and the game is not already running
- The output log can be scrolled, dragged by its scrollbar, selected with the mouse, copied with `Ctrl+C`, and fully selected with `Ctrl+A`
- The info button opens this README, and the version text opens the matching GitHub release page
- Triple right click the `Launch Game` button to use the alternate launch mode for that launch
- Starting EFU with `-DX11` makes the normal launch path use `-force-d3d11`
- If EFMI / XXMI is detected, the GUI can show an EFMI toggle attached to the launch button
- Starting EFU with `-EFMI` enables EFMI launch mode by default when the GUI opens
- Starting EFU with `--EFMI false` prevents EFU from auto-detecting XXMI and showing the EFMI button in the GUI
- If EFU is left waiting, it can still inject when the game is launched externally

### Runtime Toggle

EFU includes an Alt+F12 in-game toggle for the replacement dither patch.

- Press `Alt+F12` while the game window is active to toggle the replacement dither patch
- The hotkey is limited to the active game window so it should not fire globally while using other apps

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
- `--EFMI [PATH_TO_XXMI Launcher.exe]`: launch EFMI through XXMI, optionally using an explicit launcher path
- `--EFMI false`: prevent EFU from auto-detecting XXMI and showing the EFMI button in the GUI
- `--wm` / `--fwm` / `--force-wine-mode true|false`: GUI-only override for Wine detection
- `--am` / `--allow-minimize true|false`: GUI-only override for minimize behavior
- `--debug boxes`: show GUI development overlays for layout, hitbox, logo, text, and scrollbar bounds

### EFMI / XXMI integration

`EFMI` starts XXMI with `--nogui --xxmi EFMI` before EFU waits for Endfield and injects like normal.

If no path is supplied, EFU looks for:

`%APPDATA%\XXMI Launcher\Resources\Bin\XXMI Launcher.exe`

`DX11` and `EFMI` are mutually exclusive.
`game-path` and `EFMI` are also mutually exclusive for the same reason.
EFMI handles the game launch itself.

### Silent mode

`-silent` is intended for one-shot use. No GUI or CLI output. It requires EFU to successfully detect the normal game path or the EFMI launcher path.

---

## Building

To build from source, use Zig 0.16.0:

- [Windows x86_64](https://ziglang.org/download/0.16.0/zig-x86_64-windows-0.16.0.zip)
- [Linux x86_64](https://ziglang.org/download/0.16.0/zig-x86_64-linux-0.16.0.tar.xz)

<details>
<summary>Other Zig 0.16.0 downloads</summary>

Files are signed with [minisign](https://jedisct1.github.io/minisign/) using this public key:

```text
RWSGOq2NVecA2UPNdBUZykf1CCb147pkmdtYxgb3Ti+JO/wCYvhbAb/U
```

- 2026-04-13
- [Release Notes](https://ziglang.org/download/0.16.0/release-notes.html)
- [Language Reference](https://ziglang.org/documentation/0.16.0/)
- [Standard Library Documentation](https://ziglang.org/documentation/0.16.0/std/)

<table>
<thead>
<tr><th>OS</th><th>Arch</th><th>Filename</th><th>Signature</th><th>Size</th></tr>
</thead>
<tbody>
<tr><td colspan="2" rowspan="2" align="center">Source</td><td><a href="https://ziglang.org/download/0.16.0/zig-0.16.0.tar.xz">zig-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-0.16.0.tar.xz.minisig">minisig</a></td><td>21MiB</td></tr>
<tr><td><a href="https://ziglang.org/download/0.16.0/zig-bootstrap-0.16.0.tar.xz">zig-bootstrap-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-bootstrap-0.16.0.tar.xz.minisig">minisig</a></td><td>53MiB</td></tr>
</tbody>
<tbody>
<tr><td rowspan="3" align="center">Windows</td><td>x86_64</td><td><a href="https://ziglang.org/download/0.16.0/zig-x86_64-windows-0.16.0.zip">zig-x86_64-windows-0.16.0.zip</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-x86_64-windows-0.16.0.zip.minisig">minisig</a></td><td>93MiB</td></tr>
<tr><td>aarch64</td><td><a href="https://ziglang.org/download/0.16.0/zig-aarch64-windows-0.16.0.zip">zig-aarch64-windows-0.16.0.zip</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-aarch64-windows-0.16.0.zip.minisig">minisig</a></td><td>89MiB</td></tr>
<tr><td>x86</td><td><a href="https://ziglang.org/download/0.16.0/zig-x86-windows-0.16.0.zip">zig-x86-windows-0.16.0.zip</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-x86-windows-0.16.0.zip.minisig">minisig</a></td><td>94MiB</td></tr>
</tbody>
<tbody>
<tr><td rowspan="2" align="center">macOS</td><td>x86_64</td><td><a href="https://ziglang.org/download/0.16.0/zig-x86_64-macos-0.16.0.tar.xz">zig-x86_64-macos-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-x86_64-macos-0.16.0.tar.xz.minisig">minisig</a></td><td>55MiB</td></tr>
<tr><td>aarch64</td><td><a href="https://ziglang.org/download/0.16.0/zig-aarch64-macos-0.16.0.tar.xz">zig-aarch64-macos-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-aarch64-macos-0.16.0.tar.xz.minisig">minisig</a></td><td>50MiB</td></tr>
</tbody>
<tbody>
<tr><td rowspan="8" align="center">Linux</td><td>x86_64</td><td><a href="https://ziglang.org/download/0.16.0/zig-x86_64-linux-0.16.0.tar.xz">zig-x86_64-linux-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-x86_64-linux-0.16.0.tar.xz.minisig">minisig</a></td><td>53MiB</td></tr>
<tr><td>aarch64</td><td><a href="https://ziglang.org/download/0.16.0/zig-aarch64-linux-0.16.0.tar.xz">zig-aarch64-linux-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-aarch64-linux-0.16.0.tar.xz.minisig">minisig</a></td><td>49MiB</td></tr>
<tr><td>arm</td><td><a href="https://ziglang.org/download/0.16.0/zig-arm-linux-0.16.0.tar.xz">zig-arm-linux-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-arm-linux-0.16.0.tar.xz.minisig">minisig</a></td><td>50MiB</td></tr>
<tr><td>riscv64</td><td><a href="https://ziglang.org/download/0.16.0/zig-riscv64-linux-0.16.0.tar.xz">zig-riscv64-linux-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-riscv64-linux-0.16.0.tar.xz.minisig">minisig</a></td><td>53MiB</td></tr>
<tr><td>powerpc64le</td><td><a href="https://ziglang.org/download/0.16.0/zig-powerpc64le-linux-0.16.0.tar.xz">zig-powerpc64le-linux-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-powerpc64le-linux-0.16.0.tar.xz.minisig">minisig</a></td><td>53MiB</td></tr>
<tr><td>x86</td><td><a href="https://ziglang.org/download/0.16.0/zig-x86-linux-0.16.0.tar.xz">zig-x86-linux-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-x86-linux-0.16.0.tar.xz.minisig">minisig</a></td><td>56MiB</td></tr>
<tr><td>loongarch64</td><td><a href="https://ziglang.org/download/0.16.0/zig-loongarch64-linux-0.16.0.tar.xz">zig-loongarch64-linux-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-loongarch64-linux-0.16.0.tar.xz.minisig">minisig</a></td><td>50MiB</td></tr>
<tr><td>s390x</td><td><a href="https://ziglang.org/download/0.16.0/zig-s390x-linux-0.16.0.tar.xz">zig-s390x-linux-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-s390x-linux-0.16.0.tar.xz.minisig">minisig</a></td><td>52MiB</td></tr>
</tbody>
<tbody>
<tr><td rowspan="5" align="center">FreeBSD</td><td>aarch64</td><td><a href="https://ziglang.org/download/0.16.0/zig-aarch64-freebsd-0.16.0.tar.xz">zig-aarch64-freebsd-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-aarch64-freebsd-0.16.0.tar.xz.minisig">minisig</a></td><td>49MiB</td></tr>
<tr><td>arm</td><td><a href="https://ziglang.org/download/0.16.0/zig-arm-freebsd-0.16.0.tar.xz">zig-arm-freebsd-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-arm-freebsd-0.16.0.tar.xz.minisig">minisig</a></td><td>50MiB</td></tr>
<tr><td>powerpc64le</td><td><a href="https://ziglang.org/download/0.16.0/zig-powerpc64le-freebsd-0.16.0.tar.xz">zig-powerpc64le-freebsd-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-powerpc64le-freebsd-0.16.0.tar.xz.minisig">minisig</a></td><td>53MiB</td></tr>
<tr><td>riscv64</td><td><a href="https://ziglang.org/download/0.16.0/zig-riscv64-freebsd-0.16.0.tar.xz">zig-riscv64-freebsd-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-riscv64-freebsd-0.16.0.tar.xz.minisig">minisig</a></td><td>53MiB</td></tr>
<tr><td>x86_64</td><td><a href="https://ziglang.org/download/0.16.0/zig-x86_64-freebsd-0.16.0.tar.xz">zig-x86_64-freebsd-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-x86_64-freebsd-0.16.0.tar.xz.minisig">minisig</a></td><td>53MiB</td></tr>
</tbody>
<tbody>
<tr><td rowspan="4" align="center">NetBSD</td><td>aarch64</td><td><a href="https://ziglang.org/download/0.16.0/zig-aarch64-netbsd-0.16.0.tar.xz">zig-aarch64-netbsd-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-aarch64-netbsd-0.16.0.tar.xz.minisig">minisig</a></td><td>49MiB</td></tr>
<tr><td>arm</td><td><a href="https://ziglang.org/download/0.16.0/zig-arm-netbsd-0.16.0.tar.xz">zig-arm-netbsd-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-arm-netbsd-0.16.0.tar.xz.minisig">minisig</a></td><td>51MiB</td></tr>
<tr><td>x86</td><td><a href="https://ziglang.org/download/0.16.0/zig-x86-netbsd-0.16.0.tar.xz">zig-x86-netbsd-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-x86-netbsd-0.16.0.tar.xz.minisig">minisig</a></td><td>56MiB</td></tr>
<tr><td>x86_64</td><td><a href="https://ziglang.org/download/0.16.0/zig-x86_64-netbsd-0.16.0.tar.xz">zig-x86_64-netbsd-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-x86_64-netbsd-0.16.0.tar.xz.minisig">minisig</a></td><td>53MiB</td></tr>
</tbody>
<tbody>
<tr><td rowspan="4" align="center">OpenBSD</td><td>aarch64</td><td><a href="https://ziglang.org/download/0.16.0/zig-aarch64-openbsd-0.16.0.tar.xz">zig-aarch64-openbsd-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-aarch64-openbsd-0.16.0.tar.xz.minisig">minisig</a></td><td>49MiB</td></tr>
<tr><td>arm</td><td><a href="https://ziglang.org/download/0.16.0/zig-arm-openbsd-0.16.0.tar.xz">zig-arm-openbsd-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-arm-openbsd-0.16.0.tar.xz.minisig">minisig</a></td><td>50MiB</td></tr>
<tr><td>riscv64</td><td><a href="https://ziglang.org/download/0.16.0/zig-riscv64-openbsd-0.16.0.tar.xz">zig-riscv64-openbsd-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-riscv64-openbsd-0.16.0.tar.xz.minisig">minisig</a></td><td>53MiB</td></tr>
<tr><td>x86_64</td><td><a href="https://ziglang.org/download/0.16.0/zig-x86_64-openbsd-0.16.0.tar.xz">zig-x86_64-openbsd-0.16.0.tar.xz</a></td><td><a href="https://ziglang.org/download/0.16.0/zig-x86_64-openbsd-0.16.0.tar.xz.minisig">minisig</a></td><td>54MiB</td></tr>
</tbody>
</table>

</details>

Build the single-binary launcher with:

```bash
zig build
```

The default build uses `ReleaseSmall` and writes:

```bash
./zig-out/bin/EFU.exe
```

The normal build embeds the patch DLL instead of writing a separate DLL beside the EXE.

Target defaults:

- Windows host: DLL native, EXE `x86_64-windows-gnu`
- Non-Windows host: DLL and EXE `x86_64-windows-gnu`

Use `-Dtarget`, `-Ddll-abi=msvc|gnu`, or `-Dexe-abi=native|msvc|gnu` to override this.

To build only the DLL artifact:

```bash
zig build -DLL
```

This writes:

```bash
./zig-out/bin/EFU.dll
```

Build metadata such as the app version, output names, manifest execution level, and Windows version-info strings are generated from `build.efu.zon`.

---

## Versioning

Normally, Endfield Uncensored versions use three parts:

- `major`: large releases with major changes
- `minor`: feature updates and notable improvements
- `patch`: bug fixes and smaller updates

However, four-part version numbers are used for preview builds.<br>
The `patch` number will always be `0` in a preview build.<br>
<sub>Why would you preview a patch?</sub>

For example, `v1.2.0.3` means the third preview build leading up to `v1.2.0`'s release.

## License

Endfield Uncensored is licensed under the AGPL-3.0 license.

The bundled fonts are not covered by the project license. They remain under their own licenses, which are included alongside them. See [Inter OFL](https://github.com/DynamiByte/Endfield-Uncensored/blob/master/fonts/Inter/OFL.txt), [JetBrains Mono OFL](https://github.com/DynamiByte/Endfield-Uncensored/blob/master/fonts/JetBrainsMono/OFL.txt), and [DejaVuSansMono LICENSE](https://github.com/DynamiByte/Endfield-Uncensored/blob/master/fonts/DejaVuSansMono/LICENSE).

---

## Links

- Releases: [GitHub Releases](https://github.com/DynamiByte/Endfield-Uncensored/releases)
- GameBanana: [Endfield Uncensored](https://gamebanana.com/mods/651108)
- Issues: [GitHub Issues](https://github.com/DynamiByte/Endfield-Uncensored/issues)
- Discord: [`dynamicbyte`](https://discord.com/users/1077491551267213392)
