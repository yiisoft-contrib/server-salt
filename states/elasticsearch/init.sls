# http://www.hackzine.org/deploying-an-elasticsearch-cluster-via-saltstack.html
# Include the ``java`` sls in order to use oracle_java_pkg
java_pkg:
  pkg.installed:
    - pkgs:
      {% if grains['oscodename'] == 'bullseye' %}
      - openjdk-11-jdk
      - openjdk-11-jre
      {% elif grains['oscodename'] == 'buster' %}
      - openjdk-11-jdk
      - openjdk-11-jre
      {% elif grains['oscodename'] == 'stretch' %}
      - openjdk-9-jdk
      - openjdk-9-jre
      {% else %}
      - openjdk-7-jdk
      - openjdk-7-jre
      {% endif %}

elasticsearch_repo:
    pkgrepo.managed:
        - humanname: Elasticsearch Official Debian Repository
        {% if grains['oscodename'] == 'bullseye' or grains['oscodename'] == 'buster' %}
        - name: deb https://artifacts.elastic.co/packages/7.x/apt stable main
        {% elif grains['oscodename'] == 'stretch' %}
        - name: deb https://artifacts.elastic.co/packages/5.x/apt stable main
        {% else %}
        - name: deb http://packages.elastic.co/elasticsearch/2.x/debian stable main
        {% endif %}
        - dist: stable
        - key_url: salt://elasticsearch/GPG-KEY-elasticsearch
        - file: /etc/apt/sources.list.d/elasticsearch.list

elasticsearch:
    pkg.installed:
        - require:
            - pkg: java_pkg
            - pkgrepo: elasticsearch_repo
    service.running:
        - enable: True
        - require:
            - pkg: elasticsearch
        - watch:
            - file: /etc/elasticsearch/elasticsearch.yml

/etc/elasticsearch/elasticsearch.yml:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - source: salt://elasticsearch/etc/elasticsearch/elasticsearch.yml

#/etc/elasticsearch/logging.yml:
  #  file:
    #  - managed
    #- user: root
    #- group: root
    #- mode: 644
    #- template: jinja
    #    - source: salt://db/elasticsearch/etc/elasticsearch/logging.yml

# log rotation
/etc/logrotate.d/elasticsearch:
  file.managed:
    - source: salt://elasticsearch/etc/logrotate.d/elasticsearch

# for backup
#
# get all snapshots:
# curl -XGET "localhost:9200/_snapshot/backups/_all?pretty"
#
# http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-snapshots.html

/var/backups/elasticsearch:
  file.directory:
    - user: elasticsearch
    - group: elasticsearch
    - mode: 750
    - makedirs: True

#create_backup:
#  cmd.run:
#    - name: |
#       curl -s -XPUT 'http://localhost:9200/_snapshot/backups' -d '{
#           "type": "fs",
#           "settings": {"location": "/var/backups/elasticsearch", "compress": true}
#       }'
#    - require:
#      - file: /var/backups/elasticsearch
#      - service: elasticsearch
#
#elasticsearch_backup_cron:
#  cron.present:
#    - identifier: elasticsearch-backup
#    - name: |
#       curl -s -XPUT "localhost:9200/_snapshot/backups/snapshot_$(date +\%Y-\%m-\%d.\%H)?wait_for_completion=true" --silent --show-error > /tmp/elasticsearch-backup-result && ( grep -v '"failed":0' /tmp/elasticsearch-backup-result || true)
#    - user: root
#    - minute: 15
#    #- hour: '*/3'

# ensure user backups can read elasticserach backup in /var/backups/elasticsearch
elasticsearch_backup_permissions:
  cmd.run:
    - name: adduser backups elasticsearch
    - unless: "groups backups |grep '\\belasticsearch\\b'"

# log4j fix
/etc/default/elasticsearch:
  file.replace:
    - pattern: '^#?ES_JAVA_OPTS=.*$'
    - repl: 'ES_JAVA_OPTS=-Dlog4j2.formatMsgNoLookups=true'
    - append_if_not_found: True
    - show_changes: True
    - watch_in:
        - service: elasticsearch

