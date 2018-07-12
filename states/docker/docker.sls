

docker_packages:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg2
      - software-properties-common

docker_repo:
  pkgrepo.managed:
    - humanname: Docker Official Debian Repository
#    - name: 'deb [arch=amd64] https://download.docker.com/linux/debian {{ grains['oscodename'] }} stable'
    - name: 'deb [arch=amd64] https://download.docker.com/linux/debian stretch stable'
    - dist: stretch
    - key_url: https://download.docker.com/linux/debian/gpg
    - file: /etc/apt/sources.list.d/docker.list
    - require:
      - pkg: docker_packages

docker-ce:
  pkg.installed:
    - require:
      - pkgrepo: docker_repo

