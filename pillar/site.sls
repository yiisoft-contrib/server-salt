ssl:
  acme-certs:
    - domains:
        - yiiframework.com
        - www.yiiframework.com
        - new.yiiframework.com
      webdir: /var/www/yiiframework/web
    - domains:
        - user-content.yiiframework.com
      webdir: /var/www/yiiframework/web

php:
  version: 7.4
  extensions:
    - mysql

composer-home: /root/.composer
