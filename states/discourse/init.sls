
include:
  # install nginx
  - nginx.nginx
  # install acme for letsencrypt SSL certificate
  - acme.certs
  - docker.docker
  - postfix.postfix
  - .postfix-config
  - postfix.ssl-client
  - .discourse


# configure nginx proxy
/etc/nginx/sites-enabled/discourse:
  file.managed:
    - source: salt://discourse/etc/nginx/sites-enabled/discourse
    - template: jinja
    - watch_in:
      - service: nginx_service2

/etc/nginx/conf.d/discourse.conf:
  file.managed:
    - source: salt://discourse/etc/nginx/conf.d/discourse.conf
    - template: jinja
    - watch_in:
      - service: nginx_service2

nginx_test_config2:
  cmd.run:
    - name: nginx -t
    - unless: nginx -t

nginx_service2:
  service.running:
    - name: nginx
    - reload: True
    - require_in:
      - cmd: acme_cert_{{ (pillar.ssl['acme-certs']|first).domains|first }}
    - require:
      - cmd: nginx_test_config2

/etc/nginx/sites-enabled/discourse-ssl:
  file.managed:
    - source: salt://discourse/etc/nginx/sites-enabled/discourse-ssl
    - template: jinja
    - watch_in:
      - service: nginx_service
    - require:
      - cmd: acme_cert_{{ (pillar.ssl['acme-certs']|first).domains|first }}
    - require_in:
      - cmd: nginx_test_config

# remove config file if nginx config test fails
rm /etc/nginx/sites-enabled/discourse-ssl:
  cmd.run:
    - onfail:
      - cmd: nginx_test_config


/var/www/errorpages:
  file.recurse:
    - source: salt://discourse/errorpages

