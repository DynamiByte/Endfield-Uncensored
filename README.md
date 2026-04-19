# Endfield Uncensored

A small Vulkan focused mod that removes transparency-based censorship filters from *Arknights: Endfield*.

Why? Endfield can run like shit on DX11.
Even reported memory leaks on 50 Series Nvidia GPUs.
Some people may have it better on DX11 (they're using ancient GPUs that barely support Vulkan).
Just test the game on both APIs and see which you like better! Either way, this mod can serve you. It works with either API.
It was just made with Vulkan in mind, since 3DMigoto is not made for Vulkan.

![Version](https://img.shields.io/badge/version-4.0.0-blue)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

A full GUI was implemented in Zig, better than ever, with a custom graphics library.
You can also launch this in CLI mode by adding `-cli` as an argument.
Maybe I'll add something like `-EFMI [PATH_TO_XXMI]` in the future.

---

## Disclaimer

**THIS SOFTWARE IS NOT AFFILIATED WITH, ENDORSED BY, OR SPONSORED BY HYPERGRYPH, GRYPHLINE, OR ANY OTHER ENTITY ASSOCIATED WITH ARKNIGHTS: ENDFIELD.**

- This project is an **independent, community-driven tool** created for educational and research purposes only.  
- **I (DynamiByte) do not own, claim ownership of, or have any rights to Arknights: Endfield or any of its assets.**  
- This tool **modifies game files at runtime** which may violate the game's Terms of Service.  
- I am not responsible for your misuse of this project leading to bans, or anything of the sort. **Use at your own risk.**

This comes with the same risk as anything regarding this kind of game modding, such as anything 3DMigoto (ZZMI, GIMI, WWMI, SRMI, XXMI, etc.)  
If your antivirus flags this, I'm trying to avoid that, so do tell! For Windows Defender/Security, select "Allow on device."

---

## How-to
1. Download the latest release fron the [Releases](https://github.com/DynamiByte/Endfield-Uncensored/releases) page
2. Download and run `EFU.exe` from below. **It requires Administrator** 
3. It will likely find the game for you, allowing you to press the "Launch Game" button in the program. It will launch the game with the mod.
4. If it does not find the game, or you dont feel like pressing the "Launch Game" button, you can launch the game as you normally would and it will inject the mod automatically.
5. Press the "Minimize on injection" button to stop the program from closing after injection, instead, minimizing. When the game closes, the program's window will restore, and be ready to auto inject again. You may want to do this in case Endfield updates in game and needs to restart.

### Notes

This is also on GameBanana, [here](https://gamebanana.com/mods/651108).

If you want to build it yourself, you'll need Zig [`0.16.0-dev.2736`](https://ziglang.org/builds/zig-x86_64-windows-0.16.0-dev.2736+3b515fbed.zip)
The command I use to build is `zig build -Doptimize=ReleaseSmall`

If you want to use your own injector, you can find a prebuilt DLL from the [zip file here](https://github.com/DynamiByte/Endfield-Uncensored/releases/tag/v3.0.0). To build it yourself you'll need to modify the build script, or build from V3 source (The DLL code remains the same anyway, so it does not matter).

If you have any issues or ideas on what to add to the program, please submit them to the issue [tracker](https://github.com/DynamiByte/Endfield-Uncensored/issues), or contact me on Discord, my username is ["dynamicbyte"](https://discord.com/users/1077491551267213392). I want your input!