debconf-utils:
  pkg.installed

{% set mysql_root_pw = salt['random.get_str'](20) %}

mysql_setup:
  debconf.set:
    - name: mysql-server
    - data:
        'mysql-server/root_password': {'type': 'password', 'value': "{{ mysql_root_pw }}" }
        'mysql-server/root_password_again': {'type': 'password', 'value': '{{ mysql_root_pw }}' }
    - require:
      - pkg: debconf-utils
    - unless: test -f /root/my.cnf

/root/my.cnf:
  file.managed:
    - contents: |
        [client]
        password={{ mysql_root_pw }}
        [mysqldump]
        password={{ mysql_root_pw }}
        max_allowed_packet = 128M
        ignore-table = mysql.events
        [mysqladmin]
        password={{ mysql_root_pw }}
        [mysqlcheck]
        password={{ mysql_root_pw }}
    - onchanges:
      - pkg: mysql-server


python-mysqldb:
  pkg.installed

mysql-server:
  pkg.installed:
    - require:
      - debconf: mysql-server
      - pkg: python-mysqldb

mysql:
  service.running:
    - enable: True
    - watch:
      - pkg: mysql-server
      - file: /etc/mysql/mariadb.conf.d/60-custom.cnf

{% set mysql_user_pw = salt['random.get_str'](20) %}

mysql_user:
  mysql_user.present:
    - name: yiiframework
    - host: localhost
    - password: "{{ mysql_user_pw }}"
    - connection_default_file: /root/my.cnf
    - require:
      - file: /root/my.cnf
      - pkg: mysql-server
    - unless: test -f /var/www/yiiframework/config/db.php

/var/www/yiiframework/config/db.php:
  file.managed:
    - contents: |
        <?php return [
            'dsn' => 'mysql:host=localhost;dbname=yiiframework',
            'username' => 'yiiframework',
            'password' => '{{ mysql_user_pw }}',
        ];
    - onchanges:
      - mysql_user: mysql_user
    - require:
      - git: yiiframework_git

mysql_db:
  mysql_database.present:
    - name: yiiframework
    - character_set: utf8mb4

mysql_forumdb:
  mysql_database.present:
    - name: yiisite
    - character_set: utf8mb4

mysql_permissions:
  mysql_grants.present:
    - grant: all privileges
    - database: 'yiiframework.*'
    - user: yiiframework
    - require:
      - mysql_user: yiiframework
      - mysql_database: yiiframework

mysql_permissions_forum_read:
  mysql_grants.present:
    - grant: select,insert
    - database: 'yiisite.ipb_members'
    - user: yiiframework
    - require:
      - mysql_user: yiiframework
      - mysql_database: yiisite

mysql_permissions_forum_write:
  mysql_grants.present:
    - grant: select
    - database: 'yiisite.*'
    - user: yiiframework
    - require:
      - mysql_user: yiiframework
      - mysql_database: yiisite

/etc/mysql/mariadb.conf.d/60-custom.cnf:
  file.managed:
    - source: salt://services/yiiframework/etc/mysql/mariadb.conf.d/60-custom.cnf
    - require:
      - pkg: mysql-server

/var/backups/mysql:
  file.directory:
    - user: root
    - group: root
    - mode: '0750'

mysql_backup_cron:
  cron.present:
    - identifier: yiiframework-mysql-backup
    - name: 'mysqldump yiiframework > /var/backups/mysql/yiiframework-`date +\%F_\%H.\%M`.sql'
    - user: root
    - minute: 15
    - hour: '*/3'

#mysql_backup_forum_cron:
#  cron.absent:
#    - identifier: yiiframework-mysql-backup-forum
#    - name: 'mysqldump -h 127.0.0.1 -P 3307 -uroot yiisite > /var/backups/mysql/yiisite-`date +\%F_\%H.\%M`.sql'
##    - user: root
##    - minute: 40
##    - hour: '*'

