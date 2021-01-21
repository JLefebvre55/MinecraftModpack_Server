# MinecraftModpack_Server
A server package for [my personal Technic Launcher modpack](). Minecraft 1.12.2, Forge 1.12.2-14.23.5.2847.

[![Build Status](https://travis-ci.com/JLefebvre55/MinecraftModpack_Server.svg?branch=master)](https://travis-ci.com/JLefebvre55/MinecraftModpack_Server)

# How to use?

## Prerequisites

- Java 1.8 (and **set your damn environment variables**!)
- A clone of this repository
- Brain cells

### Windows

1. Optionally: Edit `launch.bat` and set your preferred maximum RAM allocation value (defaults to 4GB).
2. Run `launch.bat`. Let it do it's thing, and when it stops, open `eula.txt` and agree.
4. Run `launch.bat`. Use as normal.

### MacOS & Linux

1. Optionally: Edit `launch.sh` and set your preferred maximum RAM allocation value (defaults to 4GB).
2. Navigate to your repo clone in the terminal.
3. Execute `chmod +x launch.sh`, then `./launch.sh` from the terminal. Let it do it's thing, and when it stops, open `eula.txt` and agree.
4. Execute `./launch.sh`. Use as normal.

## Known Errors

There seem to be some errors loading certain IC2 Classic acheivements and SimplePlanes crafting recipes. The mods seem to work fine otherwise.

# Development

## Todo

- [ ] Don't download client-only mods
- [ ] Dockerize dis bih