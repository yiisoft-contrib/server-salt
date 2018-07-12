
discourse_pkgs:
  pkg.installed:
    - pkgs:
      - git

discourse_git:
  git.latest:
    - name: https://github.com/discourse/discourse_docker.git
    - target: /var/discourse
    - rev: master
    - force_reset: True
    - force_checkout: True
    - require:
      - pkg: docker-ce
      - pkg: discourse_pkgs

/var/discourse/containers/app.yml:
  file.managed:
    - source: salt://discourse/app.yml
    - template: jinja
    - require:
      - git: discourse_git
    

discourse_build:
  cmd.run:
    - name: /var/discourse/launcher rebuild app
#    - name: /var/discourse/launcher bootstrap app
    - cwd: /var/discourse
    - onchanges:
      - file: /var/discourse/containers/app.yml

/var/discourse/launcher start app:
  cmd.run:
    - cwd: /var/discourse
    - require:
      - cmd: discourse_build


