
include:
  - nginx.nginx
  - acme.acme
  - .nodejs
  - .nodebb

# nginx setup

/etc/nginx/sites-enabled/nodebb:
  file.managed:
    - source: salt://nodebb/etc/nginx/sites-enabled/nodebb
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
      - cmd: acme_cert
    - require:
      - cmd: nginx_test_config2

/etc/nginx/sites-enabled/nodebb-ssl:
  file.managed:
    - source: salt://nodebb/etc/nginx/sites-enabled/nodebb-ssl
    - template: jinja
    - watch_in:
      - service: nginx_service
    - require:
      - cmd: acme_cert
    - require_in:
      - cmd: nginx_test_config

# remove config file if nginx config test fails
rm /etc/nginx/sites-enabled/nodebb-ssl:
  cmd.run:
    - onfail:
      - cmd: nginx_test_config


# acme ssl cert (letsencrypt)
acme_cert:
  cmd.run:
    - name: 'if (curl -s localhost>/dev/null); then /var/lib/acme/acme.sh --issue --home /var/lib/acme -d {{ grains.id }} -w /var/www/html ; else /var/lib/acme/acme.sh --issue --home /var/lib/acme -d {{ grains.id }} --standalone ; fi'
    - unless: test -f /var/lib/acme/{{ grains.id }}/{{ grains.id }}.cer
    - require:
        - cmd: acme_install
        - pkg: curl

