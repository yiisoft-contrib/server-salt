
# webserver for yiiframework.com

include:
  - nginx.nginx
  # pillar configured to install yiiframework.com certificate
  - nginx.acme
  - nginx.acme-certs
  - php.fpm
  - php.composer
  - db.elasticsearch # TODO
  - .mysql
  - .cronjobs
  - .imagefilter


fail2ban:
  pkg.installed

# http://salt.readthedocs.org/en/latest/ref/states/all/salt.states.git.html#interaction-with-git-repositories
yiiframework_git:
  git.latest:
    - name: https://github.com/yiisoft-contrib/yiiframework.com.git
    - rev: master
    - branch: master
    - target: /var/www/yiiframework/
    - force_reset: True
    - force_checkout: True

/var/www/yiiframework/data/files:
  file.directory:
    - user: www-data
    - group: www-data
    - recurse:
      - user
      - group
    - require:
      - git: yiiframework_git

/var/www/yiiframework/data/extensions:
  file.directory:
    - user: www-data
    - group: www-data
    - recurse:
      - user
      - group
    - require:
      - git: yiiframework_git

env_init:
  cmd.run:
    - name: /var/www/yiiframework/init --env=Production
    - onchanges:
      - git: yiiframework_git

composer:
  cmd.run:
    - name: /usr/local/bin/composer install --no-dev --no-suggest --no-interaction --no-progress --prefer-dist
    - cwd: /var/www/yiiframework
    - env:
      - HOME: '/root'
    - require:
      - cmd: env_init
    - onchanges:
      - git: yiiframework_git

#migrate:
  #  cmd.run:
    #  - name: echo "y" | ./yii migrate --interactive=0
    #- cwd: /var/www/layer5.live
    #- require:
      #  - cmd: env_init
      #- cmd: composer


/etc/nginx/sites-enabled/yiiframework:
  file.managed:
    - source: salt://services/yiiframework/etc/nginx/sites-enabled/yiiframework
    - watch_in:
      - service: nginx_service2
    - require:
      - git: yiiframework_git

nginx_test_config2:
  cmd.run:
    - name: nginx -t
    - unless: nginx -t

nginx_service2:
  service:
    - name: nginx
    - running
    - reload: True
    - require_in:
      - cmd: acme_cert_{{ (pillar.ssl['acme-certs']|first).domains|first }}
    - require:
      - cmd: nginx_test_config2

/etc/nginx/sites-enabled/yiiframework-ssl:
  file.managed:
    - source: salt://services/yiiframework/etc/nginx/sites-enabled/yiiframework-ssl
    - watch_in:
      - service: nginx_service
    - require:
      - git: yiiframework_git
      - cmd: acme_cert_{{ (pillar.ssl['acme-certs']|first).domains|first }}
    - require_in:
      - cmd: nginx_test_config


#
## npm and JS
#
nodejs:
  pkg.installed

nodejs-legacy:
  pkg.installed:
    - require:
      - pkg: nodejs

yarn_repo:
  pkgrepo.managed:
    - humanname: Yarn Official Debian Repository
    - name: deb https://dl.yarnpkg.com/debian/ stable main
    - dist: stable
    - key_url: https://dl.yarnpkg.com/debian/pubkey.gpg
    - file: /etc/apt/sources.list.d/yarn.list

yarn:
  pkg.installed:
    - require:
       - pkgrepo: yarn_repo
       - pkg: nodejs-legacy
  
install_gulp:
  cmd.run:
    - name: yarn global add gulp-cli
    - cwd: /var/www/yiiframework
    - require:
      - pkg: yarn
    - unless: which gulp

yarn_install:
  cmd.run:
    - name: yarn install
    - cwd: /var/www/yiiframework
    - require:
      - cmd: env_init
      - pkg: yarn
    - onchanges:
      - git: yiiframework_git

# build contributors page (this may take some time as it downloads a lot of user avatars from github)
# ./yii contributors/generate
contributors_gen:
  cmd.run:
    - name: php ./yii contributors/generate
    - cwd: /var/www/yiiframework
    - require:
      - cmd: composer
      - cmd: yarn_install
      - cmd: install_gulp
    - onchanges:
      - git: yiiframework_git


gulp_build:
  cmd.run:
    - name: gulp build --production
    - cwd: /var/www/yiiframework
    - require:
      - cmd: yarn_install
      - cmd: install_gulp
      - cmd: contributors_gen
    - onchanges:
      - git: yiiframework_git

yii_migrate:
  cmd.run:
    - name: php ./yii migrate/up --interactive=0
    - cwd: /var/www/yiiframework
    - require:
      - cmd: composer
    - onchanges:
      - git: yiiframework_git

yii_rbac:
  cmd.run:
    - name: php ./yii rbac/up
    - cwd: /var/www/yiiframework
    - require:
      - cmd: composer
      - cmd: yii_migrate
    - onchanges:
      - git: yiiframework_git

docs_pkg:
  pkg.installed:
    - pkgs:
      - texlive-full
      - make

#
## yii2-queue service
#

/etc/systemd/system/yiiframework-queue.service:
  file.managed:
    - source: salt://services/yiiframework/etc/systemd/system/yiiframework-queue.service

#/etc/systemd/system/yii-forum-mysql.service:
#  file.managed:
#    - source: salt://services/yiiframework/etc/systemd/system/yii-forum-mysql.service

systemd_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/yiiframework-queue.service
      - file: /etc/systemd/system/yii-forum-mysql.service

yiiframework-queue:
  service.running:
    - enable: True
    - watch:
      - git: yiiframework_git
      - file: /etc/systemd/system/yiiframework-queue.service
    - require:
      - cmd: yii_migrate
      - cmd: systemd_reload

#yii-forum-mysql:
#  service.running:
#    - enable: True
#    - watch:
#      - file: /etc/systemd/system/yii-forum-mysql.service
#    - require:
#      - cmd: systemd_reload

#
# redis
#

redis-server:
  pkg.installed

rollbar_trigger:
  cmd.run:
    - name: 'curl -XPOST https://api.rollbar.com/api/1/deploy/ -F access_token={{ pillar.yiisite.rollbar_token }} -F environment=production -F revision=$(git rev-parse --verify HEAD)'
    - cwd: /var/www/yiiframework
    - onchanges:
      - git: yiiframework_git


