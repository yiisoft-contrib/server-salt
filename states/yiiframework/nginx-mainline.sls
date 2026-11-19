/usr/share/keyrings/nginx-mainline.asc:
  file.managed:
    - source: https://nginx.org/keys/nginx_signing.key
    - source_hash: sha256=55385da31d198fa6a5012d40ae98ecb272a6c4e8fffffba94719ffd3e87de37a
    - mode: '0644'

nginx_mainline_repository:
  pkgrepo.managed:
    - name: deb [signed-by=/usr/share/keyrings/nginx-mainline.asc] https://nginx.org/packages/mainline/debian {{ grains['oscodename'] }} nginx
    - file: /etc/apt/sources.list.d/nginx-mainline.list
    - require:
      - file: /usr/share/keyrings/nginx-mainline.asc

/etc/apt/preferences.d/99nginx-mainline:
  file.managed:
    - contents: |
        Package: nginx nginx-module-image-filter
        Pin: release o=nginx
        Pin-Priority: 900

nginx_mainline_candidate:
  cmd.run:
    - name: |
        set -eu
        apt-get -o APT::Update::Error-Mode=any update
        for package in nginx nginx-module-image-filter; do
            candidate=$(LC_ALL=C apt-cache policy "$package" | awk '$1 == "Candidate:" { print $2 }')
            if ! dpkg --validate-version "$candidate" 2>/dev/null ||
               ! dpkg --compare-versions "${candidate#*:}" ge 1.31.9; then
                printf 'No patched mainline package for %s (candidate: %s, minimum: 1.31.9)\n' "$package" "${candidate:-none}" >&2
                exit 1
            fi
        done
        printf '\nchanged=no\n'
    - stateful: True
    - require:
      - pkgrepo: nginx_mainline_repository
      - file: /etc/apt/preferences.d/99nginx-mainline

nginx_mainline_packages:
  pkg.latest:
    - pkgs:
      - nginx
      - nginx-module-image-filter
    - refresh: False
    - require:
      - cmd: nginx_mainline_candidate
    - require_in:
      - pkg: nginx

/etc/nginx/nginx.conf:
  file.managed:
    - source: salt://yiiframework/etc/nginx/nginx.conf
    - require:
      - pkg: nginx_mainline_packages
      - cmd: nginx_dns_resolver
    - require_in:
      - cmd: nginx_test_config
      - cmd: nginx_test_config2
    - watch_in:
      - service: nginx_service

/etc/nginx/conf.d/default.conf:
  file.absent:
    - require:
      - pkg: nginx_mainline_packages
    - require_in:
      - cmd: nginx_test_config
      - cmd: nginx_test_config2
    - watch_in:
      - service: nginx_service
