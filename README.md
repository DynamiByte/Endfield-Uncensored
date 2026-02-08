# Endfield Uncensored

A small Vulkan focused mod that removes transparency-based censorship filters from Arknights: Endfield

Why? Endfield runs worse DX11.
At the time of creating this, Endfield was nearly unplayable in DX11.
I'm not sure if they actually implemented optimizations, or it's just me, but DX11 isn't that bad anymore.
Though it is, and will always be worse, as Vulkan is a lower level api and blah blah, search it up.
Unless Hypergryph decides to take advantage of the detection logic within ACE to prevent this mod from working (they could do the same with 3DMigoto too y'know), it still serves a purpose.

![Version](https://img.shields.io/badge/version-1.0.1-blue)
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
3. Run `Endfield-Uncensored.exe` **It requires Administrator** 
4. Launch Endfield as you normally would, the program will inject and close automatically.

### Notes
If you dont wan't to use the GUI application, you can build EFU.dll from [source](https://github.com/DynamiByte/Endfield-Uncensored/blob/master/dll%20src/d3d12.c).
With minor modification, you can just use a 3DMigoto loader to inject this.
