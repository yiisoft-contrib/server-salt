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

Note that salt will only return and display any output when all states are applied.
On the first run this may take a long time, for discourse for example, their setup script says:

> This process may take anywhere between a few minutes to an hour, depending on your network speed
>
> Please be patient


## `discourse`

Install using `salt-ssh 'discourse.*' state.sls discourse`.

The salt state does the following:

- install docker
- install postfix for sending mails (relay via cebe.cc mail cluster)
- install discourse

You can access discourse on the server host name, e.g. `https://discourse.example.com`

### TODO

- configure backups
- configure yii integration


## `nodebb`

Install using `salt-ssh 'nodebb.*' state.sls nodebb`.

The salt state does the following:

- install nginx as a proxy
- issue a letencrypt certificate for the server name
- install postfix for sending mails (relay via cebe.cc mail cluster)
- install nodejs and yarn
- install nodebb
- setup nodebb (will print out admin username and password on first run)

You can access nodebb on the server host name, e.g. `https://nodebb.example.com`

Manual configuration steps:

- configure email to use `localhost` port `25` smtp server.

### TODO

- configure backup for `/opt/nodebb/public/uploads` and mongodb
- configure yii integration

