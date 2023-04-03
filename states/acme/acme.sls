
acme_curl_pkg:
  pkg.installed

acme_git_pkg:
  pkg.installed

acme_git:
  git.latest:
    - name: https://github.com/Neilpang/acme.sh.git
    - rev: v2.6.9
    - target: /opt/acme.sh
    - require:
        - pkg: acme_git_pkg
        - pkg: acme_curl_pkg

acme_install:
  cmd.run:
    - name: 'mkdir -p /var/lib/acme && cd /opt/acme.sh && ./acme.sh --install --nocron --home /var/lib/acme'
    - onchanges:
        - git: acme_git

# cronjob to update certs
acme_cert_cron:
  cron.present:
    - identifier: acme_cert_cron
    - name: '/var/lib/acme/acme.sh --cron --home "/var/lib/acme" > /var/log/acme.log'
    - minute: 15
    - hour: 4
    - require:
        - cmd: acme_install

# TODO acme logrotate
# TODO cron may need to restart nginx --reloadcmd "service nginx reload"


