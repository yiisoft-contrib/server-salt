
# webserver for yiiframework.com

include:
  - nginx.nginx
  # pillar configured to install yiiframework.com certificate
  - nginx.acme
  - nginx.acme-certs
  - php.fpm
  - php.composer
  - elasticsearch
  - .mysql
  - .cronjobs
  - .nginx-mainline
  - .imagefilter
  - .nvm


fail2ban:
  pkg.installed

/etc/php/{{ pillar.php.version }}/fpm/conf.d/60-yii.ini:
  file.managed:
    - contents: |
        memory_limit=350M
    - require:
        - pkg: php_fpm_packages
    - watch_in:
        - service: php_fpm_service


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
      - cmd: php_update_alternative
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
    - source: salt://yiiframework/etc/nginx/sites-enabled/yiiframework
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
    - source: salt://yiiframework/etc/nginx/sites-enabled/yiiframework-ssl
    - template: jinja
    - watch_in:
      - service: nginx_service
    - require:
      - git: yiiframework_git
      - cmd: acme_cert_{{ (pillar.ssl['acme-certs']|first).domains|first }}
      - service: php_fpm_service
    - require_in:
      - cmd: nginx_test_config


install_gulp:
  cmd.run:
    - name: '. "/opt/nvm/nvm.sh"; npm -g install gulp-cli'
    - cwd: /var/www/yiiframework
    - require:
      - cmd: install_nodejs
    - unless: '. "/opt/nvm/nvm.sh"; which gulp'

npm_install:
  cmd.run:
    - name: '. "/opt/nvm/nvm.sh"; npm install'
    - cwd: /var/www/yiiframework
    - require:
      - cmd: env_init
      - cmd: install_nodejs
    - onchanges:
      - git: yiiframework_git

# build contributors page (this may take some time as it downloads a lot of user avatars from github)
# ./yii contributors/generate
contributors_gen:
  cmd.run:
    - name: '. "/opt/nvm/nvm.sh"; php ./yii contributors/generate'
    - cwd: /var/www/yiiframework
    - require:
      - cmd: composer
      - cmd: npm_install
      - cmd: install_gulp
    - onchanges:
      - git: yiiframework_git


gulp_build:
  cmd.run:
    - name: '. "/opt/nvm/nvm.sh"; gulp build --production'
    - cwd: /var/www/yiiframework
    - require:
      - cmd: npm_install
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
      - python3-pygments

#
## yii2-queue service
#

/etc/systemd/system/yiiframework-queue.service:
  file.managed:
    - source: salt://yiiframework/etc/systemd/system/yiiframework-queue.service

#/etc/systemd/system/yii-forum-mysql.service:
#  file.managed:
#    - source: salt://services/yiiframework/etc/systemd/system/yii-forum-mysql.service

systemd_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/yiiframework-queue.service
#      - file: /etc/systemd/system/yii-forum-mysql.service

yiiframework-queue:
  service.running:
    - enable: True
    - watch:
      - git: yiiframework_git
      - file: /etc/systemd/system/yiiframework-queue.service
      - cmd: php_update_alternative
      - pkg: php_fpm_packages
    - require:
      - cmd: yii_migrate
      - cmd: systemd_reload
      - cmd: php_update_alternative

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

{% set sentry = salt['pillar.get']('yiisite:sentry', {}) or {} %}
{% if sentry.get('auth_token') and sentry.get('organization') and sentry.get('project') %}
sentry_deploy:
  cmd.run:
    - name: |
        set -eu
        revision=$(git rev-parse --verify HEAD)
        releases_url="https://sentry.io/api/0/organizations/${SENTRY_ORG}/releases/"
        release=$(php -r 'echo json_encode(["version" => $argv[1], "projects" => [$argv[2]]], JSON_THROW_ON_ERROR);' "$revision" "$SENTRY_PROJECT")

        sentry_post() {
            printf 'Authorization: Bearer %s\n' "$SENTRY_AUTH_TOKEN" |
                curl --fail --silent --show-error --max-time 30 --output /dev/null \
                    --header @- --header 'Content-Type: application/json' \
                    --data "$1" "$2"
        }

        sentry_post "$release" "$releases_url"
        sentry_post '{"environment":"production"}' "${releases_url}${revision}/deploys/"
    - cwd: /var/www/yiiframework
    - env:
        SENTRY_AUTH_TOKEN: {{ sentry.auth_token | tojson }}
        SENTRY_ORG: {{ sentry.organization | tojson }}
        SENTRY_PROJECT: {{ sentry.project | tojson }}
    - onchanges:
      - git: yiiframework_git
    - require:
      - cmd: gulp_build
      - cmd: yii_rbac
      - service: yiiframework-queue
{% endif %}

