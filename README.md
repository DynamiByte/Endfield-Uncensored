# Endfield Uncensored

A small Vulkan focused mod that removes transparency-based censorship filters from *Arknights: Endfield*.

Why? Endfield can run like shit on DX11.
Even reported memory leaks on 50 Series Nvidia GPUs.
Some people may have it better on DX11 (they're using ancient GPUs that barely support Vulkan).
Just test the game on both APIs and see which you like better! Either way, this mod can serve you. It works with either API.
It was just made with Vulkan in mind, since 3DMigoto is not made for Vulkan.

![Version](https://img.shields.io/badge/version-3.0.0-blue)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

Rewritten again, this time in Zig. Again, in hopes of improving virus detection...again.
Ideally I figure out how to have a full GUI and this kinda minimal detection. Then again, the program is super tiny now.

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

1. Download the latest ZIP file from the [Releases](https://github.com/DynamiByte/Endfield-Uncensored/releases) page.  
2. Extract both the exe and dll to the same folder and run `EFULoader.exe` **It requires Administrator**.  
3. Launch Endfield as you normally would, that could be EFMI, the official launcher, anything. So long as the terminal window is open

### Notes

If you want to build it yourself, you'll need Zig [`0.16.0-dev.2736`](https://ziglang.org/builds/zig-x86_64-windows-0.16.0-dev.2736+3b515fbed.zip)
The command I use to build is `zig build -Doptimize=ReleaseSmall`

The DLL file does not have to be loaded with EFULoader.exe, any DLL injector should work.

If you have any issues or ideas on what to add to the program, please submit them to the issue [tracker](https://github.com/DynamiByte/Endfield-Uncensored/issues), or contact me on [Discord](https://discord.com/users/1077491551267213392). I want your input!