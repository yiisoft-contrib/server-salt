nginx_pkg:
  pkg:
    - installed
    - pkgs:
      - nginx
      # things like htpasswd
      - apache2-utils

/etc/nginx:
  file.recurse:
    - source: salt://nginx/etc/nginx
    - include_empty: True
    - dir_mode: '0755'
    - file_mode: '0644'
    - template: jinja
    - require:
      - pkg: nginx_pkg

# populate nginx resolver config from /etc/resolv.conf
nginx_dns_resolver:
  cmd.run:
    - name: (echo "resolver "; cat /etc/resolv.conf |awk '{print $2}' ; echo ";") | tr '\n' ' ' > /etc/nginx/resolver.conf
    - unless: test -f /etc/nginx/resolver.conf && [ "$(stat -c %Y /etc/resolv.conf)" -lt "$(stat -c %Y /etc/nginx/resolver.conf)" ]


# protect the ssl dir:
/etc/nginx/ssl:
  file.directory:
    - user: root
    - group: root
    - mode: 700
    - recurse:
      - user
      - group
      - mode
    - require:
      - pkg: nginx_pkg

# generate DH primes
# https://weakdh.org/sysadmin.html
dh_primes:
  cmd.run:
    - name: openssl dhparam -out /etc/nginx/ssl/dhparams.pem 2048
    - unless: test -f /etc/nginx/ssl/dhparams.pem

nginx_test_config:
  cmd.run:
    - name: nginx -t
    - unless: nginx -t

nginx_service:
  service:
    - name: nginx
    - running
    - enable: True
    - reload: True
    - require:
      - cmd: nginx_test_config


