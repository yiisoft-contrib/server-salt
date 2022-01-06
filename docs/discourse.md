# `discourse` Salt States

Install using `salt-ssh '<server-name>' state.sls discourse` (replace `<server-name>` with the instance name from salt `roster` file).

The salt state does the following:

- install docker
- install postfix for sending mails (relay via cebe.cc mail cluster)
- install [discourse](https://www.discourse.org/)
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

   - `DB_HOST="localhost" DB_NAME="yiisite" DB_USER="root" DB_PW="root" TABLE_PREFIX="ipb_" IMPORT_AFTER="1970-01-01" UPLOADS="https://www.forum.yiiframework.com/ipb_uploads" AVATARS_DIR="/shared/imports/uploads/" USERDIR="user"  bundle exec ruby script/import_scripts/ipboard.rb | tee import.log`

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

