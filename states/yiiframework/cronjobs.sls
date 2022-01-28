
# cronjobs are managed in
/etc/cron.d/yiiframework:
  file.symlink:
    - target: /var/www/yiiframework/config/crontab



# legacy: delete old cronjobs (cronjobs are now managed in crontab)
{% set cronjobs = {
  "sitemap/generate": "@daily",
  "contributors/generate": "@weekly",
  "badge/update": "@hourly",
  "cron/update-packagist": "@hourly",
  "user/ranking": "@daily"
} %}


# TODO note that when changing these cronjobs, salt may not update them correctly, see
#  https://github.com/saltstack/salt/issues/38425
#  check crontab -l manually!
{% for c,i in cronjobs.items() %}

yii_cron_{{ c }}:
  cron.absent:
    - identifier: yii-cron-{{ c }}
#    - name: 'cd /var/www/yiiframework && php ./yii {{ c }} > /dev/null'
    - user: root
    - special: '{{ i }}'

{% endfor %}

