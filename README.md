# Saltsack states for Yii Framework servers

This repository contains [Saltstack](https://saltstack.com/salt-open-source/) state files for provisioning Yii Framework servers.


# Setup

You need [`salt-ssh`](https://docs.saltstack.com/en/latest/topics/ssh/index.html)
 installed and have it configured with your SSH key.

## Linux (Debian/Ubuntu)

Install `salt-ssh` via APT:

    apt-get install salt-ssh

We are currently working with version 2016.11 or higher (check with `salt-ssh --version`).

## Windows

TBD

## Mac

TBD


# Configuration

> **Note:** You need to run `salt-ssh` in the repository root directory as that is what contains the `Saltfile` that `salt-ssh` will read its configuration from.

1. Configure servers in salt roster (copy `roster.dist` to `roster` and adjust it as needed)
2. Run `salt-ssh -i '*' test.ping` to see if servers are set up correctly (`-i` on the first run to automatically accept the host keys).


# Salt States


## `discourse`

Install using `salt-ssh 'discourse.*' state.sls discourse`.

The salt state does the following:

- install docker
- ...

TODO 


## `nodebb`

Install using `salt-ssh 'nodebb.*' state.sls nodebb`.

The salt state does the following:

- install nginx as a proxy
- issue a letencrypt certificate for the server name
- install nodejs and yarn
- install nodebb
- setup nodebb (will print out admin username and password on first run)

You can access nodebb on the server host name, e.g. `https://nodebb.example.com`

### TODO

- configure backup for `/opt/nodebb/public/uploads` and mongodb
- configure yii integration

