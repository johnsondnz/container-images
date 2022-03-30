# Into
Container for deleting watched plex content and unprotected content from sonarr and NAS.  This container is designed to run and exit, recommended to run as a daily cron job.

# Config
Add file to `/app/config/config.yaml`

## Example
```
---
devel: false

plex_config:
    base_url: "http://localhost:32400"
    token: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    library_name: "TV Shows" # Name of the Library, no special characters please.

sonarr_config:
    base_url: "http://localhost:8989"
    api_key: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

protected:
    - Friends
    - Stargate SG-1
    - Stargate Origins
    - Stargate Atlantis
    - Stargate Universe
    - "Mr. Robot"
    - Game of Thrones
    - Firefly
    - The Expanse
    - "Battlestar Galactica (2003)"
    - Battlestar Galactica
    - Chernobyl
    - Breaking Bad
    - The Mandalorian
    - Obi-Wan Kenobi
    - "RuPaul's Drag Race"
    - "RuPaul's Drag Race All Stars"
    - "RuPaul's Drag Race UK"
    - "RuPaul's Drag Race UK vs The World"
    - "Canada's Drag Race"
    - "Star Trek: Discovery"
    - "Star Trek: Picard"
    - "Schitt's Creek"
    - Project Runway
    - The Pacific
    - Band of Brothers
    - Masters of the Air
```

## Runtime Example
```
➜  app git:(master) ✗ python3 main.py
[I 220330 03:15:48 logger:46] ==> Querying Plex Media Server...
[I 220330 03:15:48 logger:46] Series: 'Battlestar Galactica' is protected
[I 220330 03:15:48 logger:46] Series: 'Canada's Drag Race' is protected
[I 220330 03:15:48 logger:46] Series: 'Chernobyl' is protected
[I 220330 03:15:48 logger:46] Series: 'The Expanse' is protected
[I 220330 03:15:49 logger:46] Series: 'The Mandalorian' is protected
[I 220330 03:15:49 logger:46] Series: 'Mr. Robot' is protected
[I 220330 03:15:49 logger:46] Series: 'Project Runway' is protected
[I 220330 03:15:49 logger:46] Series: 'RuPaul's Drag Race' is protected
[I 220330 03:15:49 logger:46] Series: 'RuPaul's Drag Race UK vs The World' is protected
[I 220330 03:15:49 logger:46] Series: 'Star Trek: Discovery' is protected
[I 220330 03:15:49 logger:46] Series: 'Star Trek: Picard' is protected
[I 220330 03:15:49 logger:46] Series: 'Stargate Atlantis' is protected
[I 220330 03:15:49 logger:46] Series: 'Stargate SG-1' is protected
[I 220330 03:15:49 logger:46] Series: 'Stargate Universe' is protected
[W 220330 03:11:50 logger:38] Series: '8 Out of 10 Cats Does Countdown' s22e01 is watched, scheduling for deletion
[W 220330 03:11:50 logger:38] Series: '8 Out of 10 Cats Does Countdown' s22e02 is watched, scheduling for deletion
[W 220330 03:11:50 logger:38] Series: '8 Out of 10 Cats Does Countdown' s22e03 is watched, scheduling for deletion
[W 220330 03:11:50 logger:38] Series: '8 Out of 10 Cats Does Countdown' s22e04 is watched, scheduling for deletion
[W 220330 03:11:50 logger:38] Series: '8 Out of 10 Cats Does Countdown' s22e05 is watched, scheduling for deletion
[W 220330 03:11:50 logger:38] Series: '8 Out of 10 Cats Does Countdown' s22e06 is watched, scheduling for deletion
[I 220330 03:11:50 logger:46] ==> Querying Sonarr...
[W 220330 03:11:53 logger:38] Unmonitoring '8 Out of 10 Cats Does Countdown' season: 22, episode: 1
[W 220330 03:11:53 logger:38] Episode unmonitored, starting deletion process...
[W 220330 03:11:54 logger:38] Delete completed successfully
[W 220330 03:11:54 logger:38] Unmonitoring '8 Out of 10 Cats Does Countdown' season: 22, episode: 2
[W 220330 03:11:54 logger:38] Episode unmonitored, starting deletion process...
[W 220330 03:11:55 logger:38] Delete completed successfully
[W 220330 03:11:55 logger:38] Unmonitoring '8 Out of 10 Cats Does Countdown' season: 22, episode: 3
[W 220330 03:11:55 logger:38] Episode unmonitored, starting deletion process...
[W 220330 03:11:56 logger:38] Delete completed successfully
[W 220330 03:11:56 logger:38] Unmonitoring '8 Out of 10 Cats Does Countdown' season: 22, episode: 4
[W 220330 03:11:56 logger:38] Episode unmonitored, starting deletion process...
[W 220330 03:11:57 logger:38] Delete completed successfully
[W 220330 03:11:57 logger:38] Unmonitoring '8 Out of 10 Cats Does Countdown' season: 22, episode: 5
[W 220330 03:11:57 logger:38] Episode unmonitored, starting deletion process...
[W 220330 03:11:57 logger:38] Delete completed successfully
[W 220330 03:11:57 logger:38] Unmonitoring '8 Out of 10 Cats Does Countdown' season: 22, episode: 6
[W 220330 03:11:58 logger:38] Episode unmonitored, starting deletion process...
[W 220330 03:11:58 logger:38] Delete completed successfully
[I 220330 03:15:49 logger:46] ==> Script completed, exiting.
```