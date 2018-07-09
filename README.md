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


# Directory structure

TBD



