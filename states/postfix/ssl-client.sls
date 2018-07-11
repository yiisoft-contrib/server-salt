openssl-installed-client:
  pkg.installed:
    - name: openssl

openssl-client-newkey:
  cmd.run:
    - stateful: True
    - cwd: /etc/postfix
    - unless: test -s /etc/postfix/tls-client-req.pem
    - name: "/usr/bin/openssl req -newkey rsa:2048 -sha256 -days 3650 -nodes -keyout tls-client-key.pem -out tls-client-req.pem -subj '/C=DE/ST=NDS/L=Alfeld/O=cebe.cc/OU=Mailservers/CN={{ grains['fqdn'] }}/emailAddress=postmaster@cebe.cc'"
    - require:
      - pkg: openssl-installed-client
  file.managed:
    - name: /etc/postfix/tls-client-req.pem
    - user: root
    - group: root
    - mode: '0600'
 
openssl-client-key:
  cmd.run:
    - stateful: True
    - cwd: /etc/postfix
    - name: '/usr/bin/openssl rsa -in tls-client-key.pem -out tls-client-key.pem'
    - require:
      - cmd: openssl-client-newkey
  file.managed:
    - name: /etc/postfix/tls-client-key.pem
    - user: root
    - group: root
    - mode: '0600'
 
openssl-client-cert:
  cmd.run:
    - stateful: True
    - cwd: /etc/postfix
    - unless: test -s /etc/postfix/tls-client-cert.pem
#    - name: '/usr/bin/openssl x509 -req -sha256 -in tls-client-req.pem -days 3600 -CA tls-client-ca-cert.pem -CAkey tls-client-ca-key.pem -set_serial 01 -out tls-client-cert.pem'
    - name: '/usr/bin/openssl x509 -req -days 3650 -sha256 -in tls-client-req.pem -out tls-client-cert.pem -signkey tls-client-key.pem'
    - require:
      - cmd: openssl-client-newkey
  file.managed:
    - name: /etc/postfix/tls-client-cert.pem
    - user: root
    - group: root
    - mode: '0600'

# PFS
# http://www.heinlein-support.de/blog/security/perfect-forward-secrecy-pfs-fur-postfix-und-dovecot/

openssl-pfs-512:
  cmd.run:
    - cwd: /etc/postfix
    - name: '/usr/bin/openssl dhparam -out /etc/postfix/tls-dh_512.pem -2 512'
    - unless: test -f /etc/postfix/tls-dh_512.pem
  file.managed:
    - name: /etc/postfix/tls-dh_512.pem
    - user: root
    - group: root
    - mode: '0600'

openssl-pfs-1024:
  cmd.run:
    - cwd: /etc/postfix
    - name: '/usr/bin/openssl dhparam -out /etc/postfix/tls-dh_1024.pem -2 1024'
    - unless: test -f /etc/postfix/tls-dh_1024.pem
  file.managed:
    - name: /etc/postfix/tls-dh_1024.pem
    - user: root
    - group: root
    - mode: '0600'

