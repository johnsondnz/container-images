# Into
Container for vscode devleopment

# Usage
## Config
- `.devcontainer/devcontainer.json`
```
{
    "image": "ghcr.io/johnsondnz/container-images/devcontainer:latest",
    "extensions": [
        "github.vscode-pull-request-github",
        "ms-python.python",
        "redhat.vscode-yaml",
        "wholroyd.jinja",
        "hashicorp.terraform",
        "4ops.packer",
        "visualstudioexptteam.vscodeintellicode",
        "ms-python.vscode-pylance",
        "redhat.ansible",
        "ms-vsliveshare.vsliveshare",
        "vscode-icons-team.vscode-icons",
        "donjayamanne.githistory",
        "eamodio.gitlens",
        "mhutchie.git-graph",
        "waderyan.gitblame"
    ],
    "settings": {
        "editor.formatOnSave": true,
        "python.formatting.provider": "black",
        "python.formatting.blackArgs": [
            "-l 119"
        ],
        "python.linting.flake8Enabled": true,
        "python.linting.flake8Args": [
            "\"--ignore=E501,E722\""
        ],
        "yaml.format.printWidth": 119
    },
    "runArgs": [
        "-v",
        "${localEnv:HOME}/.ssh:/home/generic/.ssh:ro",
        "-v",
        "${localEnv:HOME}/.kube/config:/home/generic/.kube/config:ro",
        "-v",
        "${localEnv:HOME}/.gnupg/private-keys-v1.d:/home/generic/.gnupg/private-keys-v1.d:ro",
        "-v",
        "${localEnv:HOME}/.gnupg/pubring.kbx:/home/generic/.gnupg/pubring.kbx:ro",
        "-v",
        "${localEnv:HOME}/.gnupg/trustdb.gpg:/home/generic/.gnupg/trustdb.gpg:ro"
    ],
    "postCreateCommand": ".devcontainer/entrypoint.sh"
}
```

- `.devcontainer/entrypoint.sh`
```
#!/bin/bash

set -e
PATH=$PATH:~/.local/bin

echo "Configure pre-commit"
pre-commit install --install-hooks

echo "==> Install additional pip packages"
[ -s ./.devcontainer/pip-requirements.txt ] && echo "==> Install pip packages" && pip3 install --no-cache-dir -r ./.devcontainer/pip-requirements.txt || echo "==> No additional packages to install"

echo "set permissions on gnupg"
sudo chown generic:generic /home/generic/.gnupg
```
