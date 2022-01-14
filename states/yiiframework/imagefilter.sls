#
# - https://www.endpoint.com/blog/2016/05/25/caching-resizing-reverse-proxying-image-server-nginx
# - https://charlesleifer.com/blog/nginx-a-caching-thumbnailing-reverse-proxying-image-server-/
# - https://nginx.org/en/docs/http/ngx_http_image_filter_module.html
# - https://nginx.org/en/docs/http/ngx_http_secure_link_module.html
#

libnginx-mod-http-image-filter:
  pkg.installed:
    - require_in:
      - cmd: nginx_test_config

# installs secure link module
nginx-extras:
  pkg.installed:
    - require_in:
      - cmd: nginx_test_config

/etc/nginx/sites-enabled/imageproxy:
  file.managed:
    - source: salt://services/yiiframework/etc/nginx/sites-enabled/imageproxy
    - watch_in:
      - service: nginx_service
    - require:
      - cmd: acme_cert_user-content.yiiframework.com
      - pkg: nginx-extras
      - pkg: libnginx-mod-http-image-filter
    - require_in:
      - cmd: nginx_test_config


