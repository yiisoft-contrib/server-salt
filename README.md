# Saltsack states for Yii Framework servers

This repository contains [Saltstack](https://saltstack.com/salt-open-source/) state files for provisioning Yii Framework servers.

Dependencies:
- https://github.com/cebe-cc/salt-basic

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

Install `salt-ssh` via APT:

    apt-get install salt-ssh

We are currently working with version 2016.11 or higher (check with `salt-ssh --version`).

Alternatively you can install it via python pip: `pip install salt-ssh`.

## Windows

TBD

## Mac

TBD


# Configuration

> **Note:** You need to run `salt-ssh` in the repository root directory as that is what contains the `Saltfile` that `salt-ssh` will read its configuration from.

1. Configure servers in salt roster (copy `roster.dist` to `roster` and adjust it as needed)
2. Run `salt-ssh -i '*' test.ping` to see if servers are set up correctly (`-i` on the first run to automatically accept the host keys).

# Setting up a new server

For setting up a new server you need to have your public added to `/root/.ssh/authorized_keys`.
Run `salt-ssh -i 'servername' test.ping` to test the setup. It should respond with

```yaml
servername:
    True
```

If the server is set up correctly we apply the `basic` state to install some common software and configure basic stuff:

    salt-ssh 'servername' state.sls basic

# Deploying

For deplyoment, apply the state for the servers task:

    salt-ssh 'servername' state.sls <task>

`<task>` is one of the following states (as described below under "Salt States"):

- Discourse Forum: `discourse`
- :construction: Yii Website: `yiiframework` (not in this repo yet)
- :construction: Yii Github bot: `yiibot` (not in this repo yet)


# Salt States

Note that salt will only return and display any output when all states are applied.
On the first run this may take a long time, for discourse for example, their setup script says:

> This process may take anywhere between a few minutes to an hour, depending on your network speed
>
> Please be patient


## `discourse`

Install using `salt-ssh '<server-name>' state.sls discourse` (replace `<server-name>` with the instance name from salt `roster` file).

The salt state does the following:

- install docker
- install postfix for sending mails (relay via cebe.cc mail cluster)
- install discourse
- install nginx as a reverse-proxy in front of discourse

You can access discourse on the server host name, e.g. `https://discourse.example.com`

### Data import from IPB forum

Import old forum data into discourse:

1. `mysqldump yiisite --ignore-table=yiisite.tbl_session > /tmp/yiisite.sql`
2. copy dump to the new server: `scp cebe@old.yiiframework.com:/tmp/yiisite.sql /var/discourse/shared/standalone/yiisite.sql`
3. copy uploaded files to the new server: `scp cebe@old.yiiframework.com:/tmp/uploads.tgz /var/discourse/shared/standalone/uploads.tgz`
   - `cp /var/discourse/shared/standalone/uploads.tgz /var/www`
   - `cd /var/www && tar xzvf uploads.tgz`
   - `mv uploads ipb_uploads`
4. start discourse app container: `docker exec -it app bash`
   - install mysql `apt-get install mysql-server mysql-client libmysqlclient-dev`
   - `service mysql start`
   - `echo "create database yiisite" | mysql -uroot -proot`
   - `mysql -uroot -proot yiisite < /shared/yiisite.sql`
   - cleanup ipb data: https://gist.github.com/samdark/c65c22b4a63d565917360ef4b1f1d5c7
   - prepare discourse import script to have mysql client:
     - `cd /var/www/discourse`
     - `echo "gem 'mysql2'" >>Gemfile`
     - `echo "gem 'reverse_markdown'" >>Gemfile`
     - `bundle install --no-deployment`
     - make sure database access works replace `peer` with `trust` in `/etc/postgresql/10/main/pg_hba.conf`
     - `service postgresql restart`

   - apply changes to import script: https://github.com/discourse/discourse/compare/master...cebe:patch-1

   - `DB_HOST="localhost" DB_NAME="yiisite" DB_USER="root" DB_PW="root" TABLE_PREFIX="ipb_" IMPORT_AFTER="1970-01-01" UPLOADS="https://forum.yiiframework.com/ipb_uploads" AVATARS_DIR="/shared/imports/uploads/" USERDIR="user"  bundle exec ruby script/import_scripts/ipboard.rb | tee import.log`

   - if all went fine, clean up with `service mysql stop`, `apt-get purge mysql-server`, `rm -rf /var/lib/mysql`

Resources:

- https://meta.discourse.org/t/importing-xenforo-to-discourse/45232
- https://meta.discourse.org/t/migrating-from-invision-power-board-to-discourse/34639/23
- https://github.com/discourse/discourse/pull/5543
- https://meta.discourse.org/t/adding-an-offline-page-when-rebuilding/45238
- https://meta.discourse.org/t/official-single-sign-on-for-discourse-sso/13045


### TODO

- configure backups
- configure yii integration


## `nodebb`

Install using `salt-ssh '<server-name>' state.sls nodebb` (replace `<server-name>` with the instance name from salt `roster` file).

The salt state does the following:

- install nginx as a proxy
- issue a letencrypt certificate for the server name
- install postfix for sending mails (relay via cebe.cc mail cluster)
- install nodejs and yarn
- install nodebb
- setup nodebb (will print out admin username and password on first run)

You can access nodebb on the server host name, e.g. `https://nodebb.example.com`

Manual configuration steps:

- configure email in NodeBB settings to use `localhost` port `25` smtp server.

### Data import

TODO

Resources:

- https://github.com/NodeBB/NodeBB/issues/2008
- https://github.com/akhoury/nodebb-plugin-import-ipboard
- https://github.com/akhoury/nodebb-plugin-import


### TODO

- configure backup for `/opt/nodebb/public/uploads` and mongodb
- configure yii integration

