# Godot4Multiplayer
/!\ Very early stage

Godot 4 Addon for multiplayer

Uses:
- with Nakama
- IP direct

This addon include 2 parts:
- Basics UIs for multiplayer connections
- MultiplayerManager singleton to manage both Nakama/IP direct

![image](https://github.com/AurelienCaille/Godot4Multiplayer/assets/22189681/93d15880-fee5-4c83-8ce7-d2b8f0bf456f)

![image](https://github.com/AurelienCaille/Godot4Multiplayer/assets/22189681/dbc9cd68-7b29-4f69-bff1-9db76580fac0)


WIP:
- lobby manager:
  - Create private match
  - Create public match (via server side code)
  - List players in a match
  - Start match
 
- multiplayer manager:
  - use nakama multiplayer_bridge 


## Installation

1) Download the addon and its dependencies (this github is all packed!)
2) Ensure autoload is configured as:
   
![image](https://github.com/AurelienCaille/Godot4Multiplayer/assets/22189681/8a025ba4-15f2-4f7e-9021-30852e0c9c89)

dependencies:
- Nakama client https://github.com/heroiclabs/nakama-godot
- Lan Discorvery https://github.com/Nightscratch/Godot4-LAN-Servers-Discovery

## How to use

LAN doesnt need Nakama server (it will just show some errors)

The addon as its own docker-compose.yml at Multiplayer/Server for self-hosting a Nakama Server
