# Into
Container for running ansible playbooks.

# Exmaples
## SSH keys and playbook
```
docker run --rm -it \
  -v $(pwd):/data \
  -v ~/.ssh/id_rsa:/home/generic/.ssh/id_rsa:ro \
  -v ~/.ssh/id_rsa.pub:/home/generic/.ssh/id_rsa.pub:ro \
  ghcr.io/johnsondnz/container-images/devcontainer:latest \
  playbook.yaml
```

## Example Run Output
```
ansible-playbook 2.8.3
  config file = None
  configured module search path = ['/ansible/library']
  ansible python module location = /usr/lib/python3.7/site-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 3.7.3 (default, May  3 2019, 11:24:39) [GCC 8.3.0]
```
    
## Execute playbook
```
$ docker run --rm -it -v $(pwd):/data \
  ghcr.io/johnsondnz/container-images/devcontainer:latest \
  playbook.yml
```

## Execute playbook with inventory
```
$ docker run --rm -it -v $(pwd):/data \
  ghcr.io/johnsondnz/container-images/devcontainer:latest \
  playbook.yml -i inventory
```

## Execute playbook with verbose and sudo
```
$ docker run --rm -it -v $(pwd):/data \
  ghcr.io/johnsondnz/container-images/devcontainer:latest \
  playbook.yml -i inventory_file -v -K
```

# Logging
Ansible doesn't generate logs by default.  create `ansible.cfg` and add the following snippet to the `[default]` section, change as required.
```
[default]
log_path=/var/log/ansible/ansible.log
```

To create a persistent storage volume add `-v path_to_logs:/var/log/ansible` to the `docker run` command.
