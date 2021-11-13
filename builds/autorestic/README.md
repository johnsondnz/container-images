# Into
Container container restic and autorestic, plus crond.

# Config
Add file to /config/config.yaml

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
Expects
- CRONTAB: default '* * * * * echo 'hello-world''
