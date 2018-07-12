/etc/aliases:
  file.managed:
    - source: salt://postfix/etc/aliases
    - require:
      - pkg: postfix

/etc/postfix:
  file.recurse:
    - source: salt://discourse/etc/postfix
    - include_empty: True
    - dir_mode: '0755'
    - file_mode: '0644'
    - template: jinja
    - require:
      - pkg: docker-ce

newaliases:
  cmd.run:
    - onchanges:
      - file: /etc/aliases

