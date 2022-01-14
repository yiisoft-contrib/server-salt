
include:
  - nginx.nginx
  # pillar configured to install bot.yiiframework.com certificate
  - nginx.acme
  - nginx.acme-certs
  - php.fpm
  - php.composer

yiibot_git:
  git.latest:
    - name: https://github.com/yiisoft-contrib/github-bot
    - target: /var/www/yiibot

/var/www/yiibot/config.local.php:
  file.managed:
    - source: salt://services/yiibot/config.local.php
    - template: Jinja

/var/www/yiibot/runtime:
  file.directory:
    - user: www-data
    - group: www-data

/var/www/yiibot/logs:
  file.directory:
    - user: www-data
    - group: www-data

composer:
  cmd.run:
    - name: /usr/local/bin/composer install --no-dev --no-suggest --no-interaction --no-progress --prefer-dist
    - cwd: /var/www/yiibot
    - env:
      - HOME: '/root'
    - onchanges:
      - git: yiibot_git

# nginx
/etc/nginx/sites-enabled/yiibot:
  file.managed:
    - source: salt://services/yiibot/etc/nginx/sites-enabled/yiibot
    - watch_in:
      - service: nginx_service2
    - require:
      - git: yiibot_git

nginx_service2:
  service:
    - name: nginx
    - running
    - reload: True
    - require_in:
        - cmd: acme_cert_{{ (pillar.ssl['acme-certs']|first).domains|first }}

/etc/nginx/sites-enabled/yiibot-ssl:
  file.managed:
    - source: salt://services/yiibot/etc/nginx/sites-enabled/yiibot-ssl
    - watch_in:
      - service: nginx_service
    - require:
      - git: yiibot_git
      - cmd: acme_cert_{{ (pillar.ssl['acme-certs']|first).domains|first }}


