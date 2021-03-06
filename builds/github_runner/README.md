# Intoduction
Container for running Github actions locally.  The container requires a personal access token.  It will cleanup after itself when stopped or recreated.

# Environment Variables
Recommend using https://github.com/Tecnativa/docker-socket-proxy
## Personal repos
- ACCESS_TOKEN="[token]"
- GITHUB_USERNAME="[username]"
- REPOSITORY="[repository name]"
- DOCKER_HOST=tcp://localhost:2375

## Organisation Runners
- ACCESS_TOKEN="[token]"
- ORGANIZATION="[org]"
- DOCKER_HOST=tcp://localhost:2375
# docker-compose
## Personal
```
---
version: '3.6'

networks:
  default:

services:

  actions-worker-1:
    image: ghcr.io/johnsondnz/container-images/github_runner:latest
    container_name: actions-worker-1
    restart: unless-stopped
    environment:
      - ACCESS_TOKEN=<token>
      - GITHUB_USERNAME=<username>
      - REPOSITORY=<repository name>
      - DOCKER_HOST=tcp://<host or ip>:2375
    volumes:  # not required if using Tecnativa/docker-socket-proxy
      - /var/run/docker.sock:/var/run/docker.sock
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

```

## Organization
```
---
version: '3.6'

networks:
  default:

services:

  actions-worker-1:
    image: ghcr.io/johnsondnz/container-images/github_runner:latest
    container_name: actions-worker-1
    restart: unless-stopped
    environment:
      - ACCESS_TOKEN=<token>
      - ORGANIZATION=<org>
      - DOCKER_HOST=tcp://<host or ip>:2375
    volumes:  # not required if using Tecnativa/docker-socket-proxy
      - /var/run/docker.sock:/var/run/docker.sock
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

```
