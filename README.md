# Endfield Uncensored

A small Vulkan focused mod that removes transparency-based censorship filters from Arknights: Endfield

Why? Endfield runs like shit in DX11.
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![.NET Framework](https://img.shields.io/badge/.NET%20Framework-4.8-purple)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

## Disclaimer

**THIS SOFTWARE IS NOT AFFILIATED WITH, ENDORSED BY, OR SPONSORED BY HYPERGRYPH, GRYPHLINE, OR ANY OTHER ENTITY ASSOCIATED WITH ARKNIGHTS: ENDFIELD.**

- This project is an **independent, community-driven tool** created for educational and research purposes only.
- **I (DynamiByte) do not own, claim ownership of, or have any rights to Arknights: Endfield or any of its assets.**
- This tool **modifies game files at runtime** which may violate the game's Terms of Service.
- I am not responsible for your misuse of this project leading to bans, or anything of the sort. **Use at your own risk.**

This comes with the same risk as anything regarding this kind of game modding, such as anything 3DMigoto (ZZMI, GIMI, WWMI, SRMI, XXMI, etc.)
If your antivirus flags this, thats fine. For Windows Defender/Security, select "Allow on device".
If this concerns you, do note that ANY OTHER similar programs, like 3DMigoto loaders, will also be flagged by whatever flagged this.

## How-to
1. Download the latest release from the [Releases](https://github.com/DynamiByte/Endfield-Uncensored/releases) page
3. Run `Endfield Uncensored.exe` **It requires Administrator** 
4. Launch Endfield as you normally would, the program will inject and close automatically.

### Notes
If you dont wan't to use the GUI application, you can build the [d3d12.dll from source](https://github.com/DynamiByte/Endfield-Uncensored/blob/master/dll%20src/d3d12.c).
(My dumbass thought the game may want a familiar DLL name, and that it ran on DX12. This will be changed to EFU.dll next update. If this is all I change, the next update will be 1.0.1, If I also change something else thats major enough, it will be 1.1.0. Someone mentioned DLSS does not work on GameBanana, so it may be that.)
With minor modification, you can just use a 3DMigoto loader to inject this.
