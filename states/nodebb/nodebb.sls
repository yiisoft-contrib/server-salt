#
# Install nodebb following the instructions from https://docs.nodebb.org/installing/os/debian/
#
#

nodebb_pkgs:
  pkg.installed:
    - pkgs:
      - redis-server
      - imagemagick
      - git
      - build-essential

nodebb_git:
  git.latest:
    - name: https://github.com/NodeBB/NodeBB.git
    - target: /opt/nodebb
    - rev: v1.10.1
    #- branch: v1.10.x
    - force_reset: True
    - force_checkout: True
    - require:
      - pkg: nodejs
      - pkg: nodebb_pkgs

# writeable directories
/opt/nodebb/logs:
  file.directory:
    - user: nodebb
    - group: nodebb
    - recurse:
      - user
      - group
    - require:
      - user: nodebb
      - git: nodebb_git
      - cmd: /opt/nodebb/nodebb setup
    - require_in:
      - service: nodebb_service

/opt/nodebb:
  file.directory:
    - user: root
    - group: nodebb
    - mode: '0775'
    - require:
      - user: nodebb
      - git: nodebb_git
    - require_in:
      - service: nodebb_service

{% for wdir in ['/opt/nodebb/build', '/opt/nodebb/public/uploads'] %}
{{ wdir }}:
  file.directory:
    - user: root
    - group: nodebb
    - file_mode: '0664'
    - dir_mode: '0775'
    - recurse:
      - group
      - mode
    - require:
      - user: nodebb
      - git: nodebb_git
    - require_in:
      - service: nodebb_service

{% endfor %}

# install dependencies
yarn_install:
  cmd.run:
    - name: yarn install
    - cwd: /opt/nodebb
    - require:
      - pkg: yarn
    - onchanges:
      - git: nodebb_git

# mongodb
mongodb-server:
  pkg.installed:
    - pkgs:
      - mongodb-server
      - python-pymongo

mongodb_admin_user: # TODO create random admin password and configure it in ~/.mongorc.js
  cmd.run:
    - name: |
        echo 'db.createUser( {user: "admin", pwd: "admin1337", roles: [ { role: "userAdminAnyDatabase", db: "admin" } ] } )' | mongo admin
    - onchanges:
      - pkg: mongodb-server

/etc/mongodb.conf:
  file.managed:
    - source: salt://nodebb/etc/mongodb.conf
    - require:
      - pkg: mongodb-server
      - cmd: mongodb_admin_user

mongodb:
  service.running:
    - enable: True
    - watch:
      - pkg: mongodb-server
      - file: /etc/mongodb.conf

{% set mongodb_user_pw = salt['random.get_str'](16) %}

mongodb_user:
  cmd.run:
    - name: |
        echo 'db.dropUser( "nodebb" )' | mongo nodebb -u "admin" -p"admin1337" --authenticationDatabase "admin" ;
        echo 'db.createUser( { user: "nodebb", pwd: "{{ mongodb_user_pw }}", roles: [ "readWrite", { role: "clusterMonitor", db: "admin" } ] } )' | mongo nodebb -u "admin" -p"admin1337" --authenticationDatabase "admin"
    - require:
      - service: mongodb
    - unless: test -f /opt/nodebb/config.json


# nodebb setup 
/opt/nodebb/config.json:
  file.managed:
    - contents: |
        {
            "url": "https://{{ grains.id }}",
            "secret": "{{ salt['random.get_str'](32) }}",
            "database": "mongo",
            "mongo": {
                "host": "127.0.0.1",
                "port": "27017",
                "username": "nodebb",
                "password": "{{ mongodb_user_pw }}",
                "database": "nodebb"
            },
            "bind_address": "127.0.0.1",
            "port": "4576"
        }
    - onchanges:
      - cmd: mongodb_user
    - require:
      - git: nodebb_git

nodebb:
  user.present:
    - home: /opt/nodebb
    - groups:
      - www-data

/opt/nodebb/nodebb setup:
  cmd.run:
    - cwd: /opt/nodebb
    - user: nodebb
    - onchanges:
      - cmd: mongodb_user
      - git: nodebb_git

# nodebb systemd service
/etc/systemd/system/nodebb.service:
  file.managed:
    - source: salt://nodebb/etc/systemd/system/nodebb.service

systemctl daemon-reload:
  cmd.run:
    - onchanges:
      - file: /etc/systemd/system/nodebb.service

nodebb_service:
  service.running:
    - name: nodebb
    - enable: True
    - require:
      - cmd: systemctl daemon-reload
    - watch:
      - file: /etc/systemd/system/nodebb.service
      - file: /opt/nodebb/config.json

journalctl -xe -n 100:
  cmd.run:
    - onfail:
      - service: nodebb_service

