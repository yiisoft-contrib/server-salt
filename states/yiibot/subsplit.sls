
/var/www/yiibot/web/subsplit-hook.php:
  file.managed:
    - source: salt://yiibot/subsplit/subsplit-hook.php
    - template: jinja

/var/www/yii-subsplit:
  file.directory:
    - user: root
    - group: www-data
    - mode: '0775'

/var/www/.ssh:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: '0750'

# www-data user ssh key
'ssh-keygen -t rsa -N "" -f /var/www/.ssh/id_rsa':
  cmd.run:
    - user: www-data
    - unless: test -f /var/www/.ssh/id_rsa
    - require:
      - file: /var/www/.ssh

/var/www/yii-subsplit/split.php:
  file.managed:
    - source: salt://yiibot/subsplit/split.php
    - template: jinja
    - require:
      - file: /var/www/yii-subsplit

/var/www/yii-subsplit/Subsplit.php:
  file.managed:
    - source: salt://yiibot/subsplit/Subsplit.php
    - require:
      - file: /var/www/yii-subsplit

/var/www/yii-subsplit/trigger-subsplit.sh:
  file.managed:
    - source: salt://yiibot/subsplit/trigger-subsplit.sh
    - mode: '0755'
    - require:
      - file: /var/www/yii-subsplit

https://github.com/yiisoft/yii2:
  git.latest:
    - target: /var/www/yii-subsplit/.subsplit
    - user: www-data
    - force_reset: True
    - force_checkout: True
    - force_fetch: True
    - branch: master

https://github.com/dflydev/git-subsplit:
  git.latest:
    - target: /opt/git-subsplit

/opt/git-subsplit/install.sh:
  cmd.run:
    - cwd: /opt/git-subsplit
    - onchanges:
      - git: https://github.com/dflydev/git-subsplit

# define cronjob for running subsplit
yii_subsplit_cron:
  cron.present:
    - identifier: yii2-framework-subsplit
    - name: 'cd /var/www/yii-subsplit && (php split.php 2>&1 >> /var/log/subsplit.log || tail /var/log/subsplit.log)'
    - user: www-data
    - minute: '*/2'

/var/log/subsplit.log:
  file.managed:
    - user: www-data
    - group: www-data
