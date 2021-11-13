# Into
Container container restic and autorestic, plus crond.

# Config
Add file to `/config/config.yaml`

## Example
```
backends:
  temp:
    type: local
    path: /dst
locations:
  test:
    from: /src
    to:
    - temp
    hooks:
      success:
      - python3 /scripts/success.py
      failure:
      - python3 /scripts/failure.py
```

# Environment Variables
- CRONTAB: default = `* * * * * echo 'hello-world'`
- TZ: default = `UTC`

## Example
```
➜  autorestic-container git:(master) ✗ docker run -it --rm \
-v $(pwd):/src \
-v /tmp/test:/dst \
-v $(pwd)/scripts:/scripts \
-v $(pwd)/config:/config \
-e CRONTAB="* * * * * autorestic backup -c /config/config.yaml --ci -a --verbose" \
ghcr.io/johnsondnz/container-images/autorestic:latest
==> Setup Crontab with
==> Setup timezone
cp: '/usr/share/zoneinfo/UTC' and '/etc/localtime' are the same file
Nothing to do
==> Initiliase restic
Using config: 	 /config/config.yaml
> Executing: /usr/bin/restic snapshots
Everything is fine.
==> Parsing and loading cron
==> Get cron settings
* * * * * autorestic backup -c /config/config.yaml --ci -a --verbose >/proc/1/fd/1 2>/proc/1/fd/2
==> Starting cron in foreground
Using config: 	 /config/config.yaml


    Backing up location "test"

Executing under: "/src"
Backend: temp
> Executing: /usr/bin/restic backup .

Files:          51 new,     0 changed,     0 unmodified
Dirs:           29 new,     0 changed,     0 unmodified
Added to the repo: 3.892 KiB

processed 51 files, 53.174 KiB in 0:00
snapshot d89e0cf0 saved


Running hooks
> python3 /scripts/success.py
> Executing: /bin/bash -c python3 /scripts/success.py
Success


Done
```
