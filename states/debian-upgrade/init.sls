{% if grains.get('os') == 'Debian' and grains.get('oscodename') in ['bullseye', 'bookworm', 'trixie'] %}
/usr/local/sbin/yii-debian-upgrade:
  file.managed:
    - source: salt://debian-upgrade/yii-debian-upgrade
    - user: root
    - group: root
    - mode: '0755'
{% else %}
debian_upgrade_unsupported_host:
  test.fail_without_changes:
    - name: This upgrade helper requires Debian Bullseye, Bookworm, or Trixie.
{% endif %}
