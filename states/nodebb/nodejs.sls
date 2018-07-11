
# install nodejs 8 from debian backports
debian_backports:
  pkgrepo.managed:
    - humanname: Debian stretch backports
    - name: deb http://ftp.debian.org/debian stretch-backports main
    - dist: stretch-backports
    - file: /etc/apt/sources.list.d/stretch-backports.list

nodejs:
  pkg.installed:
    - pkgs:
      - nodejs
    #  - nodejs-legacy
    - repo: stretch-backports
    - require:
      - pkgrepo: debian_backports

# install yarn package manager
yarn_repo:
  pkgrepo.managed:
    - humanname: Yarn Official Debian Repository
    - name: deb https://dl.yarnpkg.com/debian/ stable main
    - dist: stable
    - key_url: https://dl.yarnpkg.com/debian/pubkey.gpg
    - file: /etc/apt/sources.list.d/yarn.list

yarn:
  pkg.installed:
    - require:
       - pkgrepo: yarn_repo
       - pkg: nodejs


