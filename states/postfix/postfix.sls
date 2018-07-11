postfix:
  pkg.installed:
    - name: postfix

  service.running:
    - name: postfix
    - enable: True
    - watch:
      - file: /etc/postfix

postfix-pcre:
  pkg.installed

