# Saltstack states for Yii Framework servers

This repository contains [Saltstack](https://saltstack.com/salt-open-source/) state files for provisioning Yii Framework servers.

Dependencies:

- https://github.com/cebe-cc/salt-basic
- https://github.com/cebe-cc/salt-nginx
- https://github.com/cebe-cc/salt-php

# Setup

Clone the repo and install submodules:

```sh
git clone git@github.com:yiisoft-contrib/server-salt.git yii-servers
cd yii-servers
git -c core.autocrlf=false -c core.eol=lf submodule update --init
cp roster.dist roster
```

Copy your private ssh key to `ssh/id_rsa`. If you have a password, remove it with `ssh-keygen -p -f ssh/id_rsa -N ''` since `salt-ssh` doesn't support entering a password.

Then run the following:

```sh
# build the container
docker compose build
# start a bash shell in the container
docker compose run --rm ct bash
# run salt-ssh commands, e.g.:
salt-ssh -i '*' test.ping
```

# Configuration

1. Configure servers in salt roster (copy `roster.dist` to `roster` and adjust it as needed)
2. For some servers you need salt pillar data with secrets that are not part of the public repo. Copy `pillar/<SERVERNAME>-secrets.dist.sls` to `pillar/<SERVERNAME>-secrets.sls` for these and fill out the missing config. For the prod servers clone the secrets repo and link them.
3. Run `salt-ssh -i '*' test.ping` to see if servers are set up correctly (`-i` on the first run to automatically accept the host keys).

# Setting up a new server

For setting up a new server you need to have your SSH public key added to `/root/.ssh/authorized_keys`.
Run `salt-ssh -i '<SERVERNAME>' test.ping` to test the setup. It should respond with

```yaml
<SERVERNAME>:
    True
```

If the server is set up correctly we apply the `basic` state to install some common software and configure basic stuff:

```sh
salt-ssh '<SERVERNAME>' state.apply basic
```

# Deploying

For deployment, apply the state for the servers (which are defined in `states/top.sls`):

```sh
salt-ssh '<SERVERNAME>' state.apply
```

You may specify `test=True`, to see if the apply command would change anything:

```sh
salt-ssh '<SERVERNAME>' state.apply test=True
```

This will apply the states as defined in `states/top.sls`.

To apply a specific states, you can specify it:

```sh
salt-ssh '<SERVERNAME>' state.apply <task>
```

`<task>` is one of the following states (as described below under "Salt States"):

- Discourse Forum: `discourse`
- Yii Website: `yiiframework`
- Yii GitHub bot: `yiibot`

## Sentry deploy reporting

To record production deploys for yiiframework.com, create a Sentry Organization Auth Token with the `org:ci` scope. Add the token and your Sentry organization and project slugs to the private `pillar/site-secrets.sls` file (see [the example pillar](pillar/site-secrets.dist.sls)). Keep the token out of the repository.

```yaml
yiisite:
  sentry:
    auth_token: <organization auth token>
    organization: <organization slug>
    project: <project slug>
```

When all three settings are present, Salt uses the deployed Git commit SHA as the Sentry release version and records a `production` deploy. If any setting is missing or blank, Salt skips Sentry reporting and continues the deployment. The app uses `SENTRY_DSN` separately for error reporting.

# Salt States

Note that salt will only return and display any output when all states are applied.
On the first run this may take a long time, for discourse for example, their setup script says:

> This process may take anywhere between a few minutes to an hour, depending on your network speed
>
> Please be patient

## Forum

For the forum states there is more documentation available here:

- `discourse` see [docs/discourse.md](docs/discourse.md)
- `nodebb` see [docs/nodebb.md](docs/nodebb.md)

## Yii Bot and Git Subsplit

See [states/yiibot/README.md](./states/yiibot/README.md).
