# Saltstack states for Yii Framework servers

This repository contains [Saltstack](https://saltstack.com/salt-open-source/) state files for provisioning Yii Framework servers.

Dependencies:
- https://github.com/cebe-cc/salt-basic
- https://github.com/cebe-cc/salt-nginx
- https://github.com/cebe-cc/salt-php

# Setup

Clone the repo and install submodules:

    git clone git@github.com:yiisoft-contrib/server-salt.git yii-servers
    cd yii-servers
    git submodule update --init

You need [`salt-ssh`](https://docs.saltstack.com/en/latest/topics/ssh/index.html)
installed and have it configured with your SSH key.
 
Copy the [roster.dist](./roster.dist)  file to `roster` and adjust it if you are not working on the live servers.
You need to configure your SSH key in the `roster` file.

## Linux (Debian/Ubuntu)

Install `salt-ssh` via Python PIP:

    apt-get install python3-pip
    pip3 install salt

We are currently working with version 3004 or higher (check with `salt-ssh --version`).

You may also use docker-compose as described below:

## Windows / Docker

At the time of this writing it seems salt-ssh is not supported on Windows, so you need a linux VM or docker container to run it.
First copy your private ssh key to `ssh/id_rsa`. If you have a password, remove it with `ssh-keygen -p` since `salt-ssh` doesn't support entering a password.

Then run the following:

    # build the container
    docker-compose build
    # start a bash shell in the container
    docker-compose run --rm ct bash
    # run salt-ssh commands, e.g.:
    salt-ssh -i '*' test.ping

## Mac

TBD


# Configuration

> **Note:** You need to run `salt-ssh` in the repository root directory as that is what contains the `Saltfile` that `salt-ssh` will read its configuration from.

1. Configure servers in salt roster (copy `roster.dist` to `roster` and adjust it as needed)
2. For some servers you need salt pillar data with secrets that are not part of the public repo. Copy `pillar/<SERVERNAME>-secrets.dist.sls` to `pillar/<SERVERNAME>-secrets.sls` for these and fill out the missing config.
3. Run `salt-ssh -i '*' test.ping` to see if servers are set up correctly (`-i` on the first run to automatically accept the host keys).

# Setting up a new server

For setting up a new server you need to have your SSH public key added to `/root/.ssh/authorized_keys`.
Run `salt-ssh -i '<SERVERNAME>' test.ping` to test the setup. It should respond with

```yaml
<SERVERNAME>:
    True
```

If the server is set up correctly we apply the `basic` state to install some common software and configure basic stuff:

    salt-ssh '<SERVERNAME>' state.apply basic

# Deploying

For deployment, apply the state for the servers (which are defined in `states/top.sls`):

    salt-ssh '<SERVERNAME>' state.apply

You may specify `test=True`, to see if the apply command would change anything:

    salt-ssh '<SERVERNAME>' state.apply test=True

This will apply the states as defined in `states/top.sls`.

To apply a specific states, you can specify it:

    salt-ssh '<SERVERNAME>' state.apply <task>

`<task>` is one of the following states (as described below under "Salt States"):

- Discourse Forum: `discourse`
- Yii Website: `yiiframework`
- Yii GitHub bot: `yiibot`


# Salt States

Note that salt will only return and display any output when all states are applied.
On the first run this may take a long time, for discourse for example, their setup script says:

> This process may take anywhere between a few minutes to an hour, depending on your network speed
>
> Please be patient

For the forum states there is more documentation available here:

- `discourse` see [docs/discourse.md](docs/discourse.md)
- `nodebb` see [docs/nodebb.md](docs/nodebb.md)

